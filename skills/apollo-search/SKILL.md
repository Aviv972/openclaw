---
name: apollo-search
description: Search Apollo for Portuguese real estate ICP leads (People API Search + Organization Search)
metadata:
  openclaw:
    emoji: 🔍
    requires:
      bins:
        - curl
    env:
      - APOLLO_API_KEY
---

# Apollo Search Skill

Search Apollo for PT real estate ICP leads. Two endpoints available:

| Endpoint | Path | Credits | Returns |
|----------|------|---------|---------|
| [People API Search](https://docs.apollo.io/reference/people-api-search) | `/mixed_people/api_search` | No | People (name, title, org) — no emails |
| [Organization Search](https://docs.apollo.io/reference/organization-search) | `/mixed_companies/search` | Yes | Companies (name, domain, phone) |

**Auth:** `x-api-key` header. **Base URL:** `https://api.apollo.io/api/v1`. **Params:** Query string only.

## Usage

Search for ICP leads with default filters (Portugal, Real Estate, C-suite/Director/Owner, 10–200 employees):

```
apollo-search
```

Search with a custom location filter:

```
apollo-search location="Porto"
```

Search with a custom segment:

```
apollo-search segment="luxury"
```

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `location` | `Portugal` | City or country filter (e.g. "Lisbon", "Porto", "Algarve") |
| `segment` | `all` | Target segment: `luxury`, `residential`, `commercial`, or `all` |
| `per_page` | `25` | Number of results to return (max 100) |

## Implementation

The skill calls Apollo's [People API Search](https://docs.apollo.io/reference/people-api-search) endpoint. Uses query params (not JSON body). Auth via `x-api-key` header.

```bash
curl -s -X POST "https://api.apollo.io/api/v1/mixed_people/api_search?organization_locations[]=Portugal&organization_num_employees_ranges[]=1,10&organization_num_employees_ranges[]=11,50&organization_num_employees_ranges[]=51,200&person_seniorities[]=c_suite&person_seniorities[]=director&person_seniorities[]=owner&person_seniorities[]=partner&page=1&per_page=25" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $APOLLO_API_KEY" \
  -H "Cache-Control: no-cache"
```

**Key details:**
- Base URL: `https://api.apollo.io/api/v1` (note `/api/` in path)
- Endpoint: `/mixed_people/api_search` (not `/mixed_people/search`)
- Auth: `x-api-key` header (required)
- Params: passed as query string, not request body
- This endpoint does not return emails — use People Enrichment to get contact details

## Output Format

For each lead, return (api_search gives name, title, org — use People Enrichment for email):

```
Name: [First name + last_name_obfuscated from response]
Title: [Job title]
Agency: [Organization name]
Location: Portugal (organization_locations)
ICP match reason: [1-sentence reason why this contact matches the ICP]
```

Note: People API Search does not return email addresses. Use the People Enrichment endpoint with person `id` to get contact details.

---

## Organization Search (alternative)

Use [Organization Search](https://docs.apollo.io/reference/organization-search) to find companies first. **Consumes credits.** Same base URL and auth.

```bash
curl -s -X POST "https://api.apollo.io/api/v1/mixed_companies/search?organization_locations[]=Portugal&organization_num_employees_ranges[]=1,10&organization_num_employees_ranges[]=11,50&organization_num_employees_ranges[]=51,200&q_organization_keyword_tags[]=real%20estate&page=1&per_page=25" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $APOLLO_API_KEY" \
  -H "Cache-Control: no-cache"
```

**Returns:** Organizations (id, name, website_url, primary_domain, phone). Use `organization_ids[]` from results in People API Search to find contacts at those companies.

**Key params:** `organization_locations[]`, `organization_num_employees_ranges[]`, `q_organization_keyword_tags[]` (e.g. "real estate"), `page`, `per_page`.

---

## Filters Applied (ICP-aligned)

- **Country:** Portugal only
- **Industry:** Real Estate
- **Seniority:** C-suite, Director, Owner, Partner
- **Company size:** 10–200 employees
- **Exclude:** Portals (Idealista, Imovirtual), individual agents, PropTech platforms

## Error Handling

- If `APOLLO_API_KEY` is not set → abort with: "Error: APOLLO_API_KEY env var not set. Add it to ~/.openclaw/.env"
- If API returns 401 → abort with: "Error: Apollo API key invalid or expired"
- If API returns 403 / API_INACCESSIBLE → "This endpoint requires a paid Apollo plan. Upgrade at app.apollo.io"
- If API returns 0 results → report: "No leads found for this filter. Try broadening location or segment."
- If API returns 429 → wait 60s and retry once, then abort with rate limit message

## Notes

- Apollo PT real estate data can be thinner than US/UK — if results are sparse (<10 leads), suggest supplementing with LinkedIn manual exports or Kaspr
- Always cross-check returned emails against `memory-context.md` do-not-contact list before adding to any campaign
- Do not export more than 100 leads per run to stay within Apollo's export quotas
