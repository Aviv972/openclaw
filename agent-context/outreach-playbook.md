# Cold Outreach Playbook

## Lead Sourcing from CSV (MANDATORY — do NOT simulate)

### Step 1: Get domains — use READ tool (NOT web_fetch)
The CSV is a **local file** in your workspace. Use the **read** tool:
- Path: `docs/PT-luxury-agencies.csv`
- Do NOT use web_fetch for the CSV — it is not a URL. Use **read** to open the file.

If read fails, use this list: portadafrente.com, sothebysrealtypt.com, engelvoelkers.com, portugalhomes.com, dils.pt, barnes-portugal.com, kwportugal.pt, lisbonestates.com

### Step 2: Get contacts — use web_fetch on LOCAL proxy (NOT Datagma API)
Call **web_fetch** with this exact URL pattern (replace DOMAIN):
```
http://127.0.0.1:17892/find_people?domain=portadafrente.com
```
- Use `http://127.0.0.1:17892/find_people?domain=DOMAIN` — the proxy runs on the same machine as the gateway.
- Do NOT fetch `https://gateway.datagma.net/...` — that will fail. Use the local proxy URL only.
- If response is `{"code":5,"message":"Not found"}` → skip that domain. If contacts returned → use them for drafts.
- Max ~9 domains per run.

---

## Lead Eligibility Gate (MANDATORY — before any send)

**Only send to NEW leads.** Before adding any lead to a campaign or sending any email:

1. **Check `memory-context.md`** — both sections:
   - **Partners Contacted (do not re-contact):** If the lead's agency/domain is listed → skip. Do not add to campaign.
   - **Do Not Contact Domains:** If the lead's email domain matches any entry → skip. Do not add to campaign.
2. **Cross-reference:** For every lead (from Apollo, Datagma, Hunter, or manual source), verify the email domain is NOT in either list.
3. **When in doubt:** Do not send. Prefer skipping a lead over risking a re-contact.

---

## Lead Research (MANDATORY — before writing Email 1)

Before drafting any email, research each lead to find one specific personalisation hook:

1. **Agency website** — look for:
   - Current property listings (note a specific project or neighbourhood they focus on)
   - Any mention of international buyers, golden visa, or NHR
   - Whether they display a WhatsApp contact prominently
   - Any visible chatbot or lead qualification system (if yes → skip, they already have a solution)

2. **LinkedIn** (agency page + contact's profile) — look for:
   - Recent posts about team growth, new projects, or market activity
   - Contact's tenure and role (how long they've been in position)
   - Any tools or integrations they mention publicly
   - *Note: Use HTTP to fetch agency website. LinkedIn research is manual — if no hook from web data, use segment-level personalisation.*

3. **Personalisation output** — produce one sentence that can be dropped into Email 1:
   - Format: reference something real and specific (a project, a region, a recent post)
   - Example: "Vi que a [Agency] está a trabalhar no projecto [X] em [bairro]..."
   - Example: "Reparei que têm uma presença forte no mercado internacional em [cidade]..."
   - If no specific hook is found after research, use segment-level personalisation (Algarve luxury, Porto centro, etc.) — do not fabricate details

---

## Email 1 — Cold Intro

**Timing:** Day 0 (first contact)

**Subject:** Specific to their niche
- Luxury/international: "Qualificação automática de leads para agências premium"
- Residential: "Como [Agency] pode qualificar leads WhatsApp sem esforço manual"
- Commercial: "Automatização de qualificação de leads para imobiliário comercial"

**Body:** 3 sentences maximum
1. Pain point specific to their segment (WhatsApp volume, unqualified leads, after-hours enquiries)
2. PropRooster hook — WhatsApp automation for lead qualification, 24/7
3. Single CTA: 15-minute call, Calendly link

**Rules:**
- No attachments
- No PDFs
- No "Espero que este email o encontre bem" or any equivalent filler
- Reference their specific market if possible (e.g. Algarve luxury, Porto centro)
- Calendly link in Email 1 only — do not repeat in later emails. Use the actual `CALENDLY_BOOKING_URL` from env (e.g. https://calendly.com/...). Never write "[Cal.com link]" — use the real URL.
- Sign off: "Com os melhores cumprimentos" (formal) or "Com cumprimentos" (standard)

---

## Email 2 — Day 3, Social Proof

**Timing:** 3 days after Email 1, only if no reply

**Subject:** Reply to Email 1 thread (Re: [original subject])

**Body:**
- Reference pilot data: Alma Montijo, PRIORE XXI
- Use real numbers if available (conversion rates, leads qualified, response time improvement)
- No Calendly link — softer touch, build credibility only
- 4–5 sentences max
- End with an open question, not a CTA

**Pilot data to reference:**
- Alma Montijo — active pilot, conversion data available (update with real stats when known)
- PRIORE XXI — active pilot, WhatsApp widget deployed (update with real stats when known)

---

## Email 3 — Day 7, Breakup

**Timing:** 7 days after Email 1, only if no reply to Email 1 or Email 2

**Body:**
- Short. 2 sentences only.
- "É esta uma prioridade para a [Agency] este trimestre?"
- No CTA, just a question
- If no reply after this email, mark contact as exhausted — do not contact again

---

## Operational Limits (hard — do not exceed)

- **Send cap:** 30 emails per inbox per day (Instantly limit)
- **Send window:** 09:00–11:00 Europe/Lisbon only
- **PREVIEW MODE:** First run — do not load into Instantly. Produce lead list + email drafts for Aviv's review. Switch to LIVE only after approval.

---

## Sequence Rules

- **New leads only:** Never add a lead to a campaign without first checking memory-context (Partners Contacted + Do Not Contact Domains). Re-contacts are forbidden.
- **Calendly link:** Email 1 only — never in Email 2 or 3
- **Max 3 emails per contact** — no exceptions
- **Reply received:** Pause sequence immediately. Post alert to `#proprooster-outreach-log` channel with contact name, agency, email, and the reply content. (Bot chat is for commands only.)
- **Bounce:** Mark as invalid, remove from sequence, do not retry
- **Out-of-office:** Do not count as reply. Resume sequence after OOO end date if specified, or after 5 business days
- **Opt-out/unsubscribe:** Add domain to do-not-contact list in memory-context.md immediately

---

## Copy Constraints (apply to all emails)

- PT-PT throughout — spell-check for Brazilian variants (e.g. "você" is acceptable, "vc" is not)
- Never mention competitors by name
- Never make claims that cannot be backed by pilot data
- Keep sentences short — Portuguese business email is more formal but not verbose
- One idea per sentence
