#!/usr/bin/env bash
# Apollo People API Search — run via exec from OpenClaw agent
# Usage: bash scripts/apollo-search.sh [location] [per_page]
# Example: bash scripts/apollo-search.sh Portugal 25

set -euo pipefail

LOCATION="${1:-Portugal}"
PER_PAGE="${2:-25}"

ENV_FILE="${HOME}/.openclaw/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo '{"error":"APOLLO_API_KEY not found. Add to ~/.openclaw/.env"}'
  exit 1
fi

API_KEY=$(grep -E '^APOLLO_API_KEY=' "$ENV_FILE" | cut -d= -f2- | tr -d '\r\n' | xargs)
if [ -z "$API_KEY" ]; then
  echo '{"error":"APOLLO_API_KEY is empty in ~/.openclaw/.env"}'
  exit 1
fi

curl -s -X POST "https://api.apollo.io/api/v1/mixed_people/api_search?organization_locations[]=${LOCATION}&organization_num_employees_ranges[]=1,10&organization_num_employees_ranges[]=11,50&organization_num_employees_ranges[]=51,200&person_seniorities[]=c_suite&person_seniorities[]=director&person_seniorities[]=owner&person_seniorities[]=partner&q_organization_keyword_tags[]=real%20estate&page=1&per_page=${PER_PAGE}" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -H "Cache-Control: no-cache"
