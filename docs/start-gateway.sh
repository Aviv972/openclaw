#!/usr/bin/env bash
# PropRooster — Start OpenClaw gateway (with optional systemd)
# Run on VPS after configure-openclaw.sh
# Usage: bash start-gateway.sh [--systemd]

set -euo pipefail

USE_SYSTEMD="${1:-}"

if [ "$USE_SYSTEMD" = "--systemd" ]; then
  # Install as systemd service (survives reboots)
  cat > /etc/systemd/system/openclaw.service << 'EOF'
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/OpenClaw
EnvironmentFile=/root/.openclaw/.env
ExecStart=/usr/local/bin/openclaw gateway run --bind loopback --port 18789
Restart=on-failure
RestartSec=10
StandardOutput=append:/tmp/openclaw-gateway.log
StandardError=append:/tmp/openclaw-gateway.log

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable openclaw
  systemctl start openclaw
  sleep 2
  systemctl status openclaw
  echo ""
  echo "Gateway running as systemd service. Logs: tail -f /tmp/openclaw-gateway.log"
else
  # Simple nohup start
  pkill -f openclaw-gateway 2>/dev/null && echo "Stopped existing gateway" || true
  nohup openclaw gateway run --bind loopback --port 18789 > /tmp/openclaw-gateway.log 2>&1 &
  GATEWAY_PID=$!
  echo "Gateway started (PID: $GATEWAY_PID)"
  sleep 3

  # Verify
  if kill -0 $GATEWAY_PID 2>/dev/null; then
    echo "Gateway is running"
    openclaw gateway status --deep
  else
    echo "ERROR: Gateway failed to start. Check logs:"
    tail -20 /tmp/openclaw-gateway.log
    exit 1
  fi
fi

# Final Telegram probe
echo ""
echo "=== Telegram connectivity ==="
openclaw channels status --probe
