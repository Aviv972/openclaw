#!/usr/bin/env python3
"""
Datagma HTTP proxy — allows agent to fetch contacts via web_fetch (no exec needed).
Run on VPS: python3 scripts/datagma-proxy.py
Listens on http://127.0.0.1:18792/find_people?domain=avenueliving.pt
"""
import os
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "datagma-search.sh")
PORT = 18792

if not os.path.isfile(SCRIPT):
    print(f"ERROR: Script not found: {SCRIPT}", file=__import__("sys").stderr)
    raise SystemExit(2)


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


if __name__ == "__main__":
    server = HTTPServer(("127.0.0.1", PORT), Handler)
    print(f"Datagma proxy: http://127.0.0.1:{PORT}/find_people?domain=DOMAIN")
    server.serve_forever()
