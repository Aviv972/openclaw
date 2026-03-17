#!/usr/bin/env bash
# PropRooster — Set up agent context for OpenClaw
# Run this on the VPS (from /root/OpenClaw) to give the agent access to ICP, playbook, and memory.
# OpenClaw 2026.3+ uses the shared-bootstrap hook: SHARED_*.md in ~/.openclaw/shared/ are auto-injected.

set -euo pipefail

REPO_ROOT="${1:-/root/OpenClaw}"
SHARED_DIR="$HOME/.openclaw/shared"

if [ ! -d "$REPO_ROOT/agent-context" ]; then
  echo "ERROR: agent-context not found at $REPO_ROOT/agent-context"
  echo "Usage: bash setup-agent-context.sh [path-to-OpenClaw-repo]"
  exit 1
fi

echo "Setting up shared bootstrap from $REPO_ROOT/agent-context"
mkdir -p "$SHARED_DIR"

cp "$REPO_ROOT/agent-context/icp.md" "$SHARED_DIR/SHARED_icp.md"
cp "$REPO_ROOT/agent-context/outreach-playbook.md" "$SHARED_DIR/SHARED_outreach-playbook.md"
cp "$REPO_ROOT/agent-context/memory-context.md" "$SHARED_DIR/SHARED_memory-context.md"

echo "Done. Shared bootstrap files:"
ls -la "$SHARED_DIR"

echo ""
echo "Restart the gateway to pick up changes:"
echo "  pkill -f openclaw-gateway 2>/dev/null || true"
echo "  nohup openclaw gateway run --bind loopback --port 18789 > /tmp/openclaw-gateway.log 2>&1 &"
