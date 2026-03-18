#!/usr/bin/env bash
# Datagma Find People - run via exec from OpenClaw agent
# Usage: bash scripts/datagma-search.sh <domain> [job_title]
# Example: bash scripts/datagma-search.sh avenueliving.pt

set -euo pipefail

DOMAIN="${1:?Usage: datagma-search.sh DOMAIN [job_title]}"
JOB_TITLE="${2:-Marketing Manager OR Sales Manager OR Director OR Owner}"

# Load API key from ~/.openclaw/.env
ENV_FILE="${HOME}/.openclaw/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo '{"error":"DATAGMA_API_KEY not found. Add to ~/.openclaw/.env"}'
  exit 1
fi

API_KEY=$(grep -E '^DATAGMA_API_KEY=' "$ENV_FILE" | cut -d= -f2-)
if [ -z "$API_KEY" ]; then
  echo '{"error":"DATAGMA_API_KEY is empty in ~/.openclaw/.env"}'
  exit 1
fi

curl -s -G "https://gateway.datagma.net/api/ingress/v1/find_people" \
  --data-urlencode "apiId=$API_KEY" \
  --data-urlencode "domain=$DOMAIN" \
  --data-urlencode "currentJobTitle=$JOB_TITLE" \
  --data-urlencode "countries=portugal"
