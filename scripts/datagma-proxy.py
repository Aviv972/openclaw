#!/usr/bin/env python3
"""
Datagma HTTP proxy — allows agent to fetch contacts via web_fetch (no exec needed).
Run on VPS: python3 scripts/datagma-proxy.py
Listens on http://127.0.0.1:17892/find_people?domain=DOMAIN
"""
import os
import socket
import subprocess
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "datagma-search.sh")
PORT = 17892  # Outside OpenClaw range (18789-18899)

if not os.path.isfile(SCRIPT):
    print(f"ERROR: Script not found: {SCRIPT}", file=sys.stderr)
    sys.exit(2)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # quiet

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/find_people":
            params = parse_qs(parsed.query)
            domain = (params.get("domain") or [""])[0].strip()
            if not domain:
                self.send_error(400, "Missing domain parameter")
                return
            try:
                result = subprocess.run(
                    ["bash", SCRIPT, domain],
                    capture_output=True,
                    text=True,
                    timeout=30,
                    env={**os.environ, "HOME": os.environ.get("HOME", "/root")},
                )
                body = result.stdout if result.returncode == 0 else result.stderr or result.stdout
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(body.encode("utf-8"))
            except subprocess.TimeoutExpired:
                self.send_error(504, "Datagma request timed out")
            except Exception as e:
                self.send_error(500, str(e))
        else:
            self.send_error(404, "Not found")


class ReuseAddrServer(HTTPServer):
    def server_bind(self):
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        super().server_bind()


if __name__ == "__main__":
    try:
        server = ReuseAddrServer(("127.0.0.1", PORT), Handler)
        print(f"Datagma proxy: http://127.0.0.1:{PORT}/find_people?domain=DOMAIN", flush=True)
        server.serve_forever()
    except OSError as e:
        print(f"ERROR: Cannot bind to port {PORT}: {e}", file=sys.stderr)
        sys.exit(1)
