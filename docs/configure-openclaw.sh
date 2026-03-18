#!/usr/bin/env bash
# PropRooster — OpenClaw Configuration Script
# Run AFTER vps-bootstrap.sh and AFTER filling in ~/.openclaw/.env
# Usage: bash configure-openclaw.sh

set -euo pipefail

ENV_FILE="$HOME/.openclaw/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE not found."
  echo "Copy the .env.template from this repo to ~/.openclaw/.env and fill in your API keys."
  exit 1
fi

# Source env vars
set -o allexport
source "$ENV_FILE"
set +o allexport

# Check required vars
REQUIRED_VARS=(OPENAI_API_KEY TELEGRAM_BOT_TOKEN APOLLO_API_KEY)
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "ERROR: $var is not set in $ENV_FILE"
    exit 1
  fi
done
echo "All required env vars present"

# Warn on optional vars (Instantly, Cal.com, Gmail — not needed for preview test)
OPTIONAL_VARS=(INSTANTLY_API_KEY CALCOM_API_KEY GMAIL_APP_PASSWORD)
for var in "${OPTIONAL_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "WARN: $var is not set — skipping related skill registration"
  fi
done

# 1. Agent model (OpenClaw 2026.3+ uses agents.defaults; prefix with provider)
openclaw config set agents.defaults.model openai/gpt-5.4-mini

# 2. Timezone (userTimezone for system prompt)
openclaw config set agents.defaults.userTimezone Europe/Lisbon

# 3. Remove invalid memory key if present (OpenClaw 2026.3 schema doesn't include it)
openclaw config unset agents.defaults.memory 2>/dev/null || true

# 4. Telegram bot (OpenClaw 2026.3 uses botToken not token)
openclaw config set channels.telegram.botToken "$TELEGRAM_BOT_TOKEN"

# 5. Log channel (reports go here — skip if not supported)
openclaw config set channels.telegram.log_channel "#proprooster-outreach-log" 2>/dev/null || true

# 6. Workspace + agent context (skills auto-load from workspace/skills/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
openclaw config set agents.defaults.workspace "$REPO_ROOT"
mkdir -p "$HOME/.openclaw/shared"
cp "$REPO_ROOT/agent-context/icp.md" "$HOME/.openclaw/shared/SHARED_icp.md"
cp "$REPO_ROOT/agent-context/outreach-playbook.md" "$HOME/.openclaw/shared/SHARED_outreach-playbook.md"
cp "$REPO_ROOT/agent-context/memory-context.md" "$HOME/.openclaw/shared/SHARED_memory-context.md"
echo "Agent context loaded: SHARED_icp.md, SHARED_outreach-playbook.md, SHARED_memory-context.md"

# 7. Skills are auto-loaded from workspace (agents.defaults.workspace=/root/OpenClaw)
#    Skills in skills/apollo-search, skills/datagma-search, etc. are discovered automatically.
#    No "openclaw skills register" needed in OpenClaw 2026.3.

# 8. Verify
echo ""
echo "=== Probing Telegram channel ==="
openclaw channels status --probe
