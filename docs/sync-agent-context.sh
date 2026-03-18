#!/usr/bin/env bash
# PropRooster — Sync agent-context from repo to OpenClaw on VPS
# Run this on the VPS (from /root/OpenClaw) after pushing changes from local.
#
# Usage: cd /root/OpenClaw && bash docs/sync-agent-context.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED_DIR="$HOME/.openclaw/shared"

echo "1. Pulling latest from git..."
git -C "$REPO_ROOT" pull

echo ""
echo "2. Copying agent-context to ~/.openclaw/shared/..."
mkdir -p "$SHARED_DIR"
cp "$REPO_ROOT/agent-context/icp.md" "$SHARED_DIR/SHARED_icp.md"
cp "$REPO_ROOT/agent-context/outreach-playbook.md" "$SHARED_DIR/SHARED_outreach-playbook.md"
cp "$REPO_ROOT/agent-context/memory-context.md" "$SHARED_DIR/SHARED_memory-context.md"

echo ""
echo "3. Restarting OpenClaw gateway..."
if systemctl --user is-active openclaw-gateway &>/dev/null; then
  systemctl --user restart openclaw-gateway
  echo "   (restarted via systemd)"
else
  pkill -f openclaw-gateway 2>/dev/null || true
  sleep 2
  nohup openclaw gateway run --bind loopback --port 18789 > /tmp/openclaw-gateway.log 2>&1 &
  echo "   (restarted via nohup)"
fi

echo ""
echo "Done. Agent context updated. Gateway restarted."
