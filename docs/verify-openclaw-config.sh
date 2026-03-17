#!/usr/bin/env bash
# PropRooster — Verify OpenClaw configuration
# Run on the VPS to check config and agent context setup.

set -euo pipefail

echo "=== 1. Shared bootstrap files (agent context) ==="
if [ -d "$HOME/.openclaw/shared" ]; then
  ls -la "$HOME/.openclaw/shared/" 2>/dev/null || echo "Directory empty or missing"
  SHARED_COUNT=$(find "$HOME/.openclaw/shared" -name "SHARED_*.md" 2>/dev/null | wc -l)
  if [ "$SHARED_COUNT" -ge 3 ]; then
    echo "OK: $SHARED_COUNT SHARED_*.md files (agent has ICP, playbook, memory)"
  else
    echo "WARN: Expected 3 SHARED_*.md files. Run docs/setup-agent-context.sh"
  fi
else
  echo "MISSING: ~/.openclaw/shared/ — run docs/setup-agent-context.sh"
fi

echo ""
echo "=== 2. OpenClaw config ==="
openclaw config list 2>/dev/null || echo "openclaw config list failed"

echo ""
echo "=== 3. Telegram channel ==="
openclaw channels status --probe 2>/dev/null || echo "Probe failed (gateway may not be running)"

echo ""
echo "=== 4. Gateway process ==="
pgrep -fa openclaw-gateway 2>/dev/null || echo "Gateway not running"
