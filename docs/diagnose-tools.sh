#!/usr/bin/env bash
# PropRooster — Diagnose OpenClaw tools config (run on VPS)
# Usage: bash docs/diagnose-tools.sh

echo "=== OpenClaw tools config ==="
openclaw config get tools.profile 2>/dev/null || echo "(not set)"
openclaw config get tools.allow 2>/dev/null || echo "(not set)"
openclaw config get tools.deny 2>/dev/null || echo "(not set)"
openclaw config get tools.exec.host 2>/dev/null || echo "(not set)"
openclaw config get tools.exec.security 2>/dev/null || echo "(not set)"
openclaw config get tools.byProvider 2>/dev/null || echo "(not set)"

echo ""
echo "=== agents.list tools (per-agent overrides) ==="
openclaw config get agents.list 2>/dev/null || echo "(not set)"

echo ""
echo "=== Full openclaw.json tools section ==="
openclaw config get tools 2>/dev/null || echo "(not set)"
