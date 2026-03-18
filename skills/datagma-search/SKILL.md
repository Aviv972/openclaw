---
name: datagma-search
description: Find contacts at a company via Datagma (company domain + job title). Use with CSV company list for testing.
metadata:
  openclaw:
    emoji: 📋
    requires:
      bins:
        - curl
    env:
      - DATAGMA_API_KEY
---

# Datagma Search Skill

Find people at a specific company by domain and job title. Ideal for enriching a company list (e.g. from CSV). [Datagma API](https://datagmaapi.readme.io/reference/ingressservice_findpeople).

**Cost:** 10 credits per successful search, 1 credit per failed search. Free tier: 90 credits/month.

## Usage

Find Marketing/Sales contacts at a developer or agency:

```
datagma-search domain="avenueliving.pt" job_title="Marketing Manager OR Sales Manager OR Director"
```

Find with broader job titles:

```
datagma-search domain="kronoshomes.pt" job_title="Director OR Owner OR Partner"
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `domain` | Yes | Company domain (e.g. `avenueliving.pt`, `kronoshomes.pt`). Extract from Website URL in CSV. |
| `job_title` | Yes | Job title filter. Supports OR: `"Marketing Manager OR Director OR Owner"` |
| `countries` | No | Narrow by country, minimal letters (e.g. `portugal`) |
| `fuzzy` | No | `true` for broader title matches (default: false) |

## Implementation

```bash
# Find People - GET request (try apiId or api_key per Datagma docs)
curl -s -G "https://gateway.datagma.net/api/ingress/v1/find_people" \
  --data-urlencode "apiId=$DATAGMA_API_KEY" \
  --data-urlencode "domain=$DOMAIN" \
  --data-urlencode "currentJobTitle=$JOB_TITLE" \
  --data-urlencode "countries=portugal"
```

**Auth:** `apiId` or `api_key` query parameter (check [Datagma API](https://app.datagma.com/user-api) for your key). **Base URL:** `https://gateway.datagma.net/api/ingress/v1`.

## Output Format

For each person returned (up to 10 per company):

```
Name: [name]
Title: [jobTitle]
Company: [company]
Location: [location]
Email: [legacyEmail if present — may need Find Email for verified]
LinkedIn: [linkedInUrl]
```

Note: Find People may return `legacyEmail` (unverified). For verified emails use Datagma Find Email endpoint (1 credit each).

## CSV Company List (Testing)

Use `docs/Developers & real estate agencies - Developers.csv`. Extract domains from the `Website` column:

| Domain | Developer |
|---|---|
| avenueliving.pt | Avenue |
| vicproperties.pt | VIC Properties |
| kronoshomes.pt | Kronos Homes |
| martinhal.com | Martinhal |
| fercopor.pt | Fercopor |
| vilamouraworld.com | Vilamoura World |
| ombriaresort.com | Pontos Group |
| palmaresresort.com | Kronos Homes |
| verdelagoresort.com | Verdelago Group |
| vangproperties.com | Vanguard Properties |
| andaluz11.com | In Loco Investments |
| invictapark.com | Invicta Park Capital |
| valedolobo.com | Vale do Lobo |
| quintaproperty.com | QP Savills |

Run `datagma-search` for each domain with `job_title="Marketing Manager OR Sales Manager OR Director OR Owner"`.

## Error Handling

- If `DATAGMA_API_KEY` is not set → abort: "Error: DATAGMA_API_KEY env var not set. Add it to ~/.openclaw/.env"
- If API returns 401/403 → "Error: Datagma API key invalid"
- If no results → report: "No contacts found for domain $DOMAIN. Try broader job_title or different domain."
- Always cross-check returned emails against `memory-context.md` do-not-contact list before adding to any campaign.
