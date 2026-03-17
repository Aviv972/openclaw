---
name: apollo-search
description: Search Apollo for Portuguese real estate ICP leads using People Search API
metadata:
  openclaw:
    emoji: 🔍
    requires:
      bins:
        - xurl
    env:
      - APOLLO_API_KEY
---

# Apollo Search Skill

Search Apollo's People Search API for PT real estate ICP leads matching the PropRooster profile.

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

The skill calls Apollo's People Search endpoint:

```bash
xurl POST https://api.apollo.io/v1/mixed_people/search \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache" \
  -d '{
    "api_key": "'$APOLLO_API_KEY'",
    "q_organization_industry_tag_ids": ["5567cd4773696439b10b0000"],
    "person_locations": ["Portugal"],
    "person_seniorities": ["c_suite", "director", "owner", "partner"],
    "organization_num_employees_ranges": ["1,10", "11,50", "51,200"],
    "page": 1,
    "per_page": 25
  }'
```

**Industry tag ID for Real Estate:** `5567cd4773696439b10b0000`

## Output Format

For each lead, return:

```
Name: [Full name]
Title: [Job title]
Agency: [Company name]
Email: [Email address]
Location: [City, Portugal]
ICP match reason: [1-sentence reason why this contact matches the ICP]
```

## Filters Applied (ICP-aligned)

- **Country:** Portugal only
- **Industry:** Real Estate
- **Seniority:** C-suite, Director, Owner, Partner
- **Company size:** 10–200 employees
- **Exclude:** Portals (Idealista, Imovirtual), individual agents, PropTech platforms

## Error Handling

- If `APOLLO_API_KEY` is not set → abort with: "Error: APOLLO_API_KEY env var not set. Add it to ~/.openclaw/.env"
- If API returns 401 → abort with: "Error: Apollo API key invalid or expired"
- If API returns 0 results → report: "No leads found for this filter. Try broadening location or segment."
- If API returns 429 → wait 60s and retry once, then abort with rate limit message

## Notes

- Apollo PT real estate data can be thinner than US/UK — if results are sparse (<10 leads), suggest supplementing with LinkedIn manual exports or Kaspr
- Always cross-check returned emails against `memory-context.md` do-not-contact list before adding to any campaign
- Do not export more than 100 leads per run to stay within Apollo's export quotas
