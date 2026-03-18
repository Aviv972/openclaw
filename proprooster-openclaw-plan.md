# PropRooster — OpenClaw Cold Outreach Agent
## Build Plan

> **Goal**: Deploy an autonomous cold outreach agent on OpenClaw, controlled via Telegram,  
> that sources Portuguese real estate leads, builds campaigns, and books demos — overnight, unattended.

---

## Architecture Overview

```
Aviv (Telegram)
      │
      ▼
OpenClaw Agent  ←──  Skills (ICP · Playbook · Memory context)
      │
      ├──▶ Apollo        →  90+ ICP leads (PT real estate)
      ├──▶ Instantly     →  Campaigns ready to send (warm inboxes)
      ├──▶ Calendly      →  Demo meetings auto-booked
      └──▶ Gmail         →  Follow-up sequences triggered
      
      ▲
      └──  Memory layer (partners · past outreach · replies · ICP rules)

Reporting: Private Telegram channel (log) + bot chat (commands)
```

---

## Phase 1 — Infrastructure
**Time: ~30 min**

### 1.1 Hetzner VPS
- Spin up **CX11** (€3.29/mo) — Ubuntu 22.04
- SSH access, basic firewall (allow 22, 443 only)
- Install Docker if OpenClaw requires it

### 1.2 Telegram Bot Setup
```
1. Open Telegram → search @BotFather
2. /newbot → name it (e.g. "PropRooster Outreach")
3. Copy the bot token
4. Paste token into OpenClaw's Telegram connector
5. Start a chat with the bot → OpenClaw is live
```

### 1.3 Telegram Channel Setup (Reporting Log)
- Create a **private Telegram channel** (e.g. `#proprooster-outreach-log`)
- Add the bot as **admin**
- Use this channel for agent reports, lead lists, campaign previews
- Keep the bot chat for commands only — clean separation

### 1.4 OpenClaw Config
| Setting | Value |
|---|---|
| Model | GPT-4o or Claude Sonnet minimum — do NOT cheap out here |
| Memory | Persistent memory enabled — critical, set before anything else |
| Interface | Telegram bot token |
| Timezone | Europe/Lisbon |

---

## Phase 2 — Integrations
**Time: ~3h**

### 2.1 Apollo (Lead Sourcing)
- Connect API key to OpenClaw
- Pre-build a saved search in Apollo:
  - **Location**: Portugal (Lisbon, Porto, Algarve)
  - **Industry**: Real Estate
  - **Seniority**: C-suite, Director, Owner
  - **Company size**: 10–200 employees
  - **Exclude**: Property portals, individual agents, ibuyers

### 2.2 Instantly (Email Sending)
- Connect API key to OpenClaw
- Set up **2–3 warm inboxes** (do not skip warmup — 2 weeks minimum)
- Configure sending limits:
  - ≤ 30 emails/inbox/day
  - Send window: **09:00–11:00 Lisbon time**
  - PT-PT locale settings

### 2.3 Calendly (Demo Booking)
- Create event type: **"PropRooster Demo"**
  - Duration: 30 min
  - Auto-generate Zoom link
  - Buffer: 15 min before/after
  - Availability: Mon–Fri, 10:00–17:00 Lisbon
- Set `CALENDLY_BOOKING_URL` in `~/.openclaw/.env`

### 2.4 Gmail (Follow-ups)
- OAuth connection — use a **dedicated follow-up inbox**, not main
- Agent monitors for replies and triggers follow-up logic accordingly
- Link to Calendly so booked meetings trigger a confirmation email

---

## Phase 3 — Skills
**Time: ~2h — this is the critical part**

Skills are pre-loaded context files. Without them the agent invents ICP definitions,  
writes generic emails, and makes bad decisions. Build these before first run.

### `icp.md` — Who to target
```markdown
# PropRooster ICP

Target: Portuguese real estate agencies and developers
Ideal profile:
  - 5–50 agent teams
  - Active in Lisbon, Porto, or Algarve
  - Currently using WhatsApp manually to qualify leads
  - International buyer-facing (bonus: golden visa, NHR clients)

Pain we solve:
  - Agents spending hours qualifying unqualified WhatsApp leads
  - No system to handle volume from property portals at night/weekends

Not ideal:
  - Individual agents (no budget)
  - Property portals (different model)
  - iBuyers or PropTech platforms

Language: PT-PT always. Not Brazilian Portuguese.
Tone: Formal initially (vouching, não tu). 
```

### `outreach-playbook.md` — How to write
```markdown
# Cold Outreach Playbook

## Email 1 — Cold intro
Subject: specific to their niche (luxury / commercial / residential)
Body: 3 sentences max
  1. Pain point specific to their segment
  2. PropRooster hook (WhatsApp automation for lead qualification)
  3. Single CTA: 15-minute call, Calendly link

Rules:
  - No attachments
  - No PDFs
  - No "I hope this email finds you well"
  - Reference their specific market if possible (e.g. Algarve luxury)

## Email 2 — Day 3, Social proof
  - Reference pilot data: Alma Montijo, PRIORE XXI
  - Use real numbers if available (conversion rates, leads qualified)
  - No Calendly link — softer touch

## Email 3 — Day 7, Breakup
  - Short. 2 sentences.
  - "Is this a priority for [Agency] this quarter?"
  - No CTA, just a question

## Sequence rules
  - Calendly link: Email 1 only
  - Max 3 emails per contact
  - If reply → pause sequence, alert Aviv on Telegram immediately
```

### `memory-context.md` — Live state (update weekly)
```markdown
# Agent Memory Context

## Active pilots
- Alma Montijo — active, conversion data available
- PRIORE XXI — active, WhatsApp widget deployed

## Partners contacted (do not re-contact)
- [update before each run]

## Pending replies
- [update after each run]

## Campaigns sent this month
- [running count]

## Do not contact
- [list of opted-out domains/contacts]
```

---

## Phase 4 — First Run Protocol
**Run this the first time to validate the setup**

### Command to send via Telegram:
```
Run cold outreach cycle — PREVIEW MODE.

1. Find 20 ICP leads from Apollo, Lisbon residential segment.
2. Write Email 1 for each using the outreach playbook.
3. DO NOT load into Instantly yet.
4. Report back with: lead list (name, agency, email, why ICP match) 
   + 3 sample email drafts for my review.

Post report to the #proprooster-outreach-log channel.
```

> **Review the output before sending anything.**  
> Once you trust the lead quality and email copy, switch to autonomous mode.

### Autonomous mode command (once validated):
```
Run cold outreach cycle — LIVE.

1. Pull 30 ICP leads from Apollo, Lisbon/Porto residential.
2. Build 3-email sequences using outreach playbook.
3. Load campaigns into Instantly (respect daily caps).
4. Post full lead list + campaign summary to #proprooster-outreach-log.
5. Alert me immediately if any reply comes in.
```

---

## Phase 5 — PropRooster-Specific Edges

| Edge | Detail |
|---|---|
| **Pilot data as proof** | Feed Alma Montijo / PRIORE XXI numbers into Email 2. Real stats convert better than generic claims. |
| **Segment-aware tone** | Luxury agencies → more formal PT. Smaller residential → slightly warmer. Tell the agent explicitly in the ICP file. |
| **No LinkedIn from OpenClaw (yet)** | Keep LinkedIn outreach manual for now. Apollo → Instantly → Gmail is the reliable loop. |
| **Telegram formatting advantage** | Agent can send you lead tables and email previews with proper markdown formatting — much cleaner than WhatsApp. |

---

## Known Failure Modes & Mitigations

| Risk | Mitigation |
|---|---|
| **Memory drift** | Weekly Telegram command: "Summarize who replied, bounced, booked. Update memory context." |
| **Weak model** | GPT-4o or Claude Sonnet minimum. Haiku/GPT-3.5 will hallucinate leads and write bad copy. |
| **Apollo PT data quality** | PT real estate thinner than US/UK on Apollo. Supplement with LinkedIn manual exports or Kaspr for PT-specific leads. |
| **Instantly warm-up skipped** | 2-week inbox warmup minimum. Rushing this = spam folder = wasted leads. |
| **No memory on restart** | Verify persistent memory is on before first run. Without it, the agent restarts cold on every session. |

---

## Cost Estimate (Monthly)

| Item | Cost |
|---|---|
| Hetzner CX11 VPS | €3.29 |
| OpenClaw | Check current pricing |
| Apollo (starter) | ~$49 |
| Instantly (starter) | ~$37 |
| Calendly | Free (basic) |
| Gmail | Free |
| **Total** | **~€90–100/mo** |

---

## Success Metrics (First Month)

- [ ] 3 outreach campaigns live
- [ ] 200+ ICP leads sourced and sequenced
- [ ] ≥ 5% reply rate (PT cold email benchmark)
- [ ] ≥ 2 demos booked via Calendly
- [ ] Zero manual work from Aviv after setup

---

*Last updated: 2026-03-16*  
*Interface: Telegram (switched from WhatsApp — easier setup, markdown reporting, no Meta API)*
