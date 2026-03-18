#!/usr/bin/env bash
# PropRooster — Test Datagma with CSV company list
# Extracts domains from docs/Developers & real estate agencies - Developers.csv
# and runs one Datagma Find People call as a test.
#
# Prerequisites: DATAGMA_API_KEY in ~/.openclaw/.env
# Usage: cd /root/OpenClaw && bash docs/test-datagma-csv.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CSV="$REPO_ROOT/docs/Developers & real estate agencies - Developers.csv"

if [ ! -f "$CSV" ]; then
  echo "ERROR: CSV not found at $CSV"
  exit 1
fi

# Load API key
if [ -f "$HOME/.openclaw/.env" ]; then
  export $(grep -E '^DATAGMA_API_KEY=' "$HOME/.openclaw/.env" | xargs)
fi

if [ -z "${DATAGMA_API_KEY:-}" ]; then
  echo "ERROR: DATAGMA_API_KEY not set. Add it to ~/.openclaw/.env"
  echo "Get key at: https://app.datagma.com/"
  exit 1
fi

# Extract first domain from CSV (look for https:// URLs)
DOMAIN=$(grep -oE 'https?://[^,/"]+' "$CSV" | head -1 | sed 's|https\?://||' | sed 's|/.*||')

if [ -z "$DOMAIN" ]; then
  echo "ERROR: No domain found in CSV"
  exit 1
fi

echo "Testing Datagma Find People with domain: $DOMAIN"
echo ""

curl -s -G "https://gateway.datagma.net/api/ingress/v1/find_people" \
  --data-urlencode "apiId=$DATAGMA_API_KEY" \
  --data-urlencode "domain=$DOMAIN" \
  --data-urlencode "currentJobTitle=Marketing Manager OR Sales Manager OR Director OR Owner" \
  --data-urlencode "countries=portugal" | head -c 3000

echo ""
echo ""
echo "If you see people data above, Datagma is working."
echo "To test more domains, run: datagma-search domain=\"<domain>\" job_title=\"Marketing Manager OR Director\""
