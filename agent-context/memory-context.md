# Agent Memory Context

> Update this file weekly after each run via Telegram command:
> "Summarize who replied, bounced, booked. Update memory context."
> Last updated: 2026-03-16

---

## RESTRICTION: New Leads Only

**The agent must only send emails to NEW leads.** Before adding any lead to a campaign, the agent MUST check both "Partners Contacted" and "Do Not Contact Domains" below. If a lead's agency or email domain appears in either list → do not contact. Skip the lead.

---

## Active Pilots

| Agency | Status | Notes |
|---|---|---|
| Alma Montijo | Active | Conversion data available — use in Email 2 social proof |
| PRIORE XXI | Active | WhatsApp widget deployed — use in Email 2 social proof |

---

## Partners Contacted (do not re-contact)

> Add agency domains here after each outreach run. Agent must check this list before adding any lead to a campaign.

- [none yet — update before first run]

---

## Pending Replies

> Update after each run. Format: Agency | Contact | Reply date | Summary | Action needed

- [none yet]

---

## Campaigns Sent This Month

> Running count. Reset each calendar month.

- March 2026: 0 campaigns sent, 0 leads sequenced

---

## Do Not Contact Domains

> Opted-out, bounced, or disqualified. Agent must never add these to any campaign.

- [none yet]

---

## Booking Log

> Demo calls booked via Calendly. Update as bookings come in.

- [none yet]

---

## Notes for Next Run

> Any context Aviv wants the agent to carry into the next cycle.

- **Datagma lead lookup:** Use **web_fetch** with URL: `http://127.0.0.1:17892/find_people?domain=DOMAIN`. Replace DOMAIN with the company domain (e.g. avenueliving.pt). Do NOT simulate. Run the real API call.
- First run: use PREVIEW MODE — do not load into Instantly until Aviv reviews lead list and email drafts
- Inbox warmup status: confirm 2-week warmup is complete before switching to LIVE MODE
