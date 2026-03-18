# CLAUDE.md — PropRooster / OpenClaw

> Primary AI context document for Claude Code. Keep focused, structured, and updated as the project evolves.

---

## Project Overview

**Project Name:** `PropRooster — OpenClaw Cold Outreach Agent`
**Type:** `Self-hosted AI agent (OpenClaw) / automation workflow`
**Owner:** `Aviv Carmi`

Autonomous cold outreach agent running on a self-hosted OpenClaw gateway on a Hetzner VPS, controlled via Telegram. Sources PT real estate leads from Apollo, builds sequences in Instantly, and auto-books demos via Calendly.

---

## Repository Structure

```
OpenClaw/
├── CLAUDE.md                            # AI context (this file)
├── proprooster-openclaw-plan.md         # Full phased build & setup guide
│
├── agent-context/
│   ├── icp.md                           # Who to target (system prompt context)
│   ├── outreach-playbook.md             # Email sequence rules
│   └── memory-context.md               # Live state — updated after each run
│
├── skills/
│   ├── apollo-search/SKILL.md           # Custom skill: search Apollo via HTTP
│   ├── instantly-campaign/SKILL.md      # Custom skill: manage Instantly campaigns
│   └── calendly-booking/SKILL.md       # Custom skill: check Calendly bookings
│
└── docs/
    └── setup.md                         # VPS setup, env vars, openclaw.json config
```

---

## Key Components

| Component | Purpose |
|---|---|
| `proprooster-openclaw-plan.md` | Full phased build plan |
| `agent-context/icp.md` | ICP definition — injected as agent system prompt context |
| `agent-context/outreach-playbook.md` | Email rules — injected as agent context |
| `agent-context/memory-context.md` | Live state — update weekly after each run |
| `skills/apollo-search/` | Custom OpenClaw skill wrapping Apollo REST API via HTTP |
| `skills/instantly-campaign/` | Custom skill wrapping Instantly API |
| `skills/calendly-booking/` | Custom skill wrapping Calendly API |

---

## Coding Conventions

### Language & Format
- **Primary languages:** Markdown (agent context), YAML frontmatter (SKILL.md), Bash/curl (skill implementations)
- **Agent model:** Claude Sonnet (`ANTHROPIC_API_KEY`) or GPT-4o (`OPENAI_API_KEY`) minimum
- **Locale in prompts:** PT-PT throughout — never Brazilian Portuguese

### Skill Format
Every OpenClaw skill must have YAML frontmatter with:
- `name` — skill identifier
- `description` — what it does
- `metadata.openclaw` block — emoji, `requires.bins` or HTTP dependencies

`agent-context/` files are NOT skills — they are system prompt injections loaded as agent instructions.

### Operational Constraints (hard limits — not recommendations)
- **Send cap:** 30 emails/inbox/day maximum (Instantly limit)
- **Send window:** 09:00–11:00 Europe/Lisbon only
- **Warmup:** 2-week inbox warmup in Instantly required before any live send
- **First run:** Always run in PREVIEW MODE (plan Phase 4) before switching to LIVE MODE

---

## Architecture Decisions

| # | Decision | Status | Summary |
|---|---|---|---|
| ADR-001 | Telegram over WhatsApp | Accepted | Easier setup, markdown reporting, no Meta API dependency |
| ADR-002 | Himalaya skill for Gmail follow-ups | Accepted | No native Gmail skill exists; himalaya handles IMAP/SMTP including Gmail via App Password — OAuth approach described in plan Phase 2.4 is superseded by this decision |
| ADR-003 | Custom skills for Apollo/Instantly/Calendly | Accepted | No native integrations exist; build SKILL.md wrappers using HTTP calls |
| ADR-004 | Self-hosted OpenClaw on Hetzner VPS | Accepted | Docker Compose deployment via `docker-setup.sh` or `docker-compose.yml` |
| ADR-005 | Agent context files ≠ skills | Accepted | ICP/playbook/memory are system prompt injections, not SKILL.md tools |

---

## Development Workflows

### Getting Started (Hetzner VPS — Ubuntu 22.04)
```bash
# 1. Install OpenClaw
npm install -g openclaw

# 2. Configure environment
cp .env.example ~/.openclaw/.env
# Fill in: ANTHROPIC_API_KEY, TELEGRAM_BOT_TOKEN

# 3. Configure Telegram channel
openclaw config set channels.telegram.token $TELEGRAM_BOT_TOKEN

# 4. Configure agent model
openclaw config set agent.model claude-sonnet-4-6

# 5. Set timezone
openclaw config set agent.timezone Europe/Lisbon

# 6. Enable persistent memory
openclaw config set agent.memory.enabled true

# 7. Start gateway
openclaw gateway run --bind loopback --port 18789

# 8. Verify
openclaw channels status --probe
```

### Common Tasks
```bash
# View/edit OpenClaw config
openclaw config list
openclaw config set <key> <value>

# Check agent status
openclaw gateway status --deep

# Restart gateway
pkill -f openclaw-gateway
nohup openclaw gateway run --bind loopback --port 18789 > /tmp/openclaw-gateway.log 2>&1 &

# Tail logs
tail -f /tmp/openclaw-gateway.log
```

---

## Claude Instructions

### What Claude Should Always Do
- Check `agent-context/memory-context.md` before suggesting who to contact
- Reference `proprooster-openclaw-plan.md` for integration details and phase steps
- When building skills, follow OpenClaw's `SKILL.md` YAML frontmatter format (`name`, `description`, `metadata.openclaw` with emoji + `requires.bins` or HTTP deps)
- Use `openclaw config set` for all configuration — not direct file editing
- Load `agent-context/` files as agent system prompt injections, not as skills
- Recommend running in PREVIEW MODE (plan Phase 4) before any first live outreach run
- Use segment-aware tone in email copy: luxury agencies → formal PT-PT ("vouching" register); smaller residential agencies → slightly warmer
- Reference pilot data (Alma Montijo / PRIORE XXI real numbers) when drafting Email 2 social proof
- Recommend the weekly memory-update Telegram command when discussing agent state or memory drift

### What Claude Should Never Do
- Suggest Apollo/Instantly/Calendly are plug-and-play — they require custom skill wrappers
- Treat `agent-context/` files as OpenClaw skills — they are system prompt context only
- Re-contact domains listed in `agent-context/memory-context.md` do-not-contact list
- Suggest Gmail OAuth — use himalaya with App Password for IMAP/SMTP
- Modify `CLAUDE.md` unless explicitly instructed
- Commit or push code directly
- Suggest sending more than 30 emails/inbox/day or outside the 09:00–11:00 Europe/Lisbon window
- Downgrade the agent model below Claude Sonnet / GPT-4o (Haiku or GPT-3.5 will hallucinate on outreach tasks)
- Route agent output reports to the Telegram bot chat — reports go to `#proprooster-outreach-log` channel; bot chat is for commands only
- Suggest LinkedIn outreach automation from OpenClaw — LinkedIn prospecting remains manual

### Preferred Response Style
- Code-first — show the diff or the command, then explain if needed
- Concise — no lengthy preambles
- When uncertain, ask one targeted clarifying question before proceeding

---

## Skills Reference

OpenClaw has built-in skills and this project adds custom ones.

| Skill | Path | Notes |
|---|---|---|
| `himalaya` | `openclaw/openclaw:skills/himalaya` | Built-in — email CLI (IMAP/SMTP); use for Gmail follow-ups via App Password |
| `xurl` | `openclaw/openclaw:skills/xurl` | Built-in — HTTP requests; base for Apollo/Instantly/Calendly calls |
| `apollo-search` | `skills/apollo-search/SKILL.md` | Custom — to build; wraps Apollo REST API |
| `instantly-campaign` | `skills/instantly-campaign/SKILL.md` | Custom — to build; wraps Instantly API |
| `calendly-booking` | `skills/calendly-booking/SKILL.md` | Custom — to build; wraps Calendly API |

---

## Open Questions / TODOs

- [ ] Apollo PT data quality — supplement with LinkedIn manual exports or Kaspr if thin
- [ ] Configure himalaya with Gmail App Password before first run
- [ ] Build custom `SKILL.md` for Apollo, Instantly, Calendly (HTTP wrappers)
- [ ] Confirm persistent memory config (`agent.memory.enabled true`) before first run
- [ ] Populate `agent-context/memory-context.md` with current pilot data (Alma Montijo, PRIORE XXI)
- [ ] Confirm 2-week inbox warmup in Instantly before first live send
- [ ] Test Telegram channel connectivity: `openclaw channels status --probe`

---

## Changelog

| Date | Change |
|---|---|
| 2026-03-16 | Populated from template with PropRooster/OpenClaw project details |
| 2026-03-16 | Gap-fill from plan review: timezone, sending constraints, Gmail OAuth reconciliation, PREVIEW MODE, segment tone, pilot data, model floor, Telegram channel routing, LinkedIn manual note |

---

*Keep this file minimal and precise. AI context should be a signal, not noise.*
