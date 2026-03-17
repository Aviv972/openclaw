---
name: instantly-campaign
description: Create and manage Instantly email campaigns for PropRooster outreach sequences
metadata:
  openclaw:
    emoji: ⚡
    requires:
      bins:
        - xurl
    env:
      - INSTANTLY_API_KEY
---

# Instantly Campaign Skill

Create campaigns, add leads, and monitor active outreach sequences in Instantly.

**Hard limits (never override):**
- Max 30 emails/inbox/day
- Send window: 09:00–11:00 Europe/Lisbon only
- Inbox warmup: 2 weeks minimum before any live send

## Usage

Create a new campaign:

```
instantly-campaign create name="Lisbon Residential Q1 2026"
```

Add leads to an existing campaign:

```
instantly-campaign add-leads campaign_id="[ID]" leads="[JSON array]"
```

List active campaigns:

```
instantly-campaign list
```

Check campaign stats:

```
instantly-campaign stats campaign_id="[ID]"
```

## Implementation

### Create Campaign

```bash
xurl POST https://api.instantly.ai/api/v1/campaign/create \
  -H "Content-Type: application/json" \
  -d '{
    "api_key": "'$INSTANTLY_API_KEY'",
    "name": "[campaign_name]",
    "daily_limit": 30,
    "sending_gap": 45,
    "from_name": "Aviv Carmi",
    "email_list": ["[warm_inbox_email]"],
    "sequences": [
      {
        "steps": [
          {
            "type": "email",
            "delay": 0,
            "variants": [{ "subject": "[Email 1 subject]", "body": "[Email 1 body]" }]
          },
          {
            "type": "email",
            "delay": 3,
            "variants": [{ "subject": "Re: [Email 1 subject]", "body": "[Email 2 body]" }]
          },
          {
            "type": "email",
            "delay": 7,
            "variants": [{ "subject": "Re: [Email 1 subject]", "body": "[Email 3 body]" }]
          }
        ]
      }
    ],
    "schedule": {
      "timezone": "Europe/Lisbon",
      "days": { "1": true, "2": true, "3": true, "4": true, "5": true, "6": false, "7": false },
      "start_hour": "09:00",
      "end_hour": "11:00"
    }
  }'
```

### Add Leads to Campaign

```bash
xurl POST https://api.instantly.ai/api/v1/lead/add \
  -H "Content-Type: application/json" \
  -d '{
    "api_key": "'$INSTANTLY_API_KEY'",
    "campaign_id": "[campaign_id]",
    "skip_if_in_workspace": true,
    "leads": [
      {
        "email": "[lead_email]",
        "first_name": "[first_name]",
        "last_name": "[last_name]",
        "company_name": "[agency_name]",
        "personalization": "[ICP match note]"
      }
    ]
  }'
```

### List Active Campaigns

```bash
xurl GET "https://api.instantly.ai/api/v1/campaign/list?api_key=$INSTANTLY_API_KEY&limit=10&status=active"
```

### Campaign Stats

```bash
xurl GET "https://api.instantly.ai/api/v1/analytics/campaign/summary?api_key=$INSTANTLY_API_KEY&campaign_id=[campaign_id]"
```

## Output Format

After creating a campaign and adding leads, report:

```
Campaign created: [name]
Campaign ID: [id]
Leads added: [count]
Send window: Mon–Fri, 09:00–11:00 Lisbon
Daily limit: 30 emails/inbox
Estimated completion: [date]
```

## Enforced Constraints

- **Daily limit:** Always set to 30 — never higher
- **Send window:** Always 09:00–11:00 Europe/Lisbon — never override
- **Weekdays only:** Mon–Fri, never Sat/Sun
- **skip_if_in_workspace: true** — prevents double-contacting leads already in other campaigns
- **PREVIEW MODE:** In preview mode, build the campaign object and report it to Aviv — do NOT call the create endpoint. Switch to LIVE MODE only when Aviv explicitly confirms.

## Error Handling

- If `INSTANTLY_API_KEY` is not set → abort with: "Error: INSTANTLY_API_KEY env var not set. Add it to ~/.openclaw/.env"
- If API returns 401 → abort with: "Error: Instantly API key invalid or expired"
- If warmup is not confirmed → warn Aviv before creating any live campaign: "Warning: Confirm inbox warmup is complete (2 weeks minimum) before launching live campaigns"
