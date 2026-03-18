# PropRooster — OpenClaw VPS Setup

Reference guide for provisioning the Hetzner VPS and configuring the OpenClaw gateway.

---

## 1. Hetzner VPS Provisioning

1. Log in to [Hetzner Cloud Console](https://console.hetzner.cloud)
2. Create new project → **PropRooster**
3. Add Server:
   - **Type:** CX11 (€3.29/mo, 1 vCPU, 2GB RAM)
   - **OS:** Ubuntu 22.04
   - **Location:** Falkenstein or Nuremberg (EU, low latency to PT)
   - **SSH key:** Add your public key
4. Note the server IPv4 address

---

## 2. Firewall Rules

Configure via Hetzner Firewall or `ufw` on the server:

```bash
ufw allow 22/tcp    # SSH
ufw allow 443/tcp   # HTTPS (if exposing any webhook endpoint)
ufw deny incoming
ufw enable
```

OpenClaw gateway runs on port 18789 (loopback only — not exposed externally).

---

## 3. Required Environment Variables

Add all of these to `~/.openclaw/.env` on the VPS before starting the gateway.

| Variable | Description | Where to get it |
|---|---|---|
| `ANTHROPIC_API_KEY` | Claude API key (Sonnet minimum) | console.anthropic.com |
| `TELEGRAM_BOT_TOKEN` | Bot token from @BotFather | Telegram → @BotFather → /newbot |
| `APOLLO_API_KEY` | Apollo People Search API key | app.apollo.io → Settings → API |
| `DATAGMA_API_KEY` | Datagma Find People API key (testing) | app.datagma.com → API |
| `INSTANTLY_API_KEY` | Instantly campaign API key | app.instantly.ai → Settings → API |
| `CALENDLY_BOOKING_URL` | PropRooster Demo booking link (used in Email 1 CTA) | Calendly → Create "PropRooster Demo" event type → copy public link (e.g. `https://calendly.com/your-username/proprooster-demo`) |
| `GMAIL_APP_PASSWORD` | Gmail App Password for himalaya IMAP/SMTP | Google Account → Security → App Passwords |

### `.env` template

```bash
# ~/.openclaw/.env
ANTHROPIC_API_KEY=sk-ant-...
TELEGRAM_BOT_TOKEN=...
APOLLO_API_KEY=...
DATAGMA_API_KEY=...
INSTANTLY_API_KEY=...
CALENDLY_BOOKING_URL=https://calendly.com/your-username/proprooster-demo
GMAIL_APP_PASSWORD=...
```

---

## 4. OpenClaw Installation & Configuration

### Install

```bash
npm install -g openclaw
```

### Configuration sequence (8 steps — run in order)

```bash
# 1. Set agent model (OpenClaw 2026.3+ uses agents.defaults)
openclaw config set agents.defaults.model gpt-5.4-mini

# 2. Set timezone (userTimezone for system prompt)
openclaw config set agents.defaults.userTimezone Europe/Lisbon

# 3. Enable persistent memory (if supported — OpenClaw 2026.3+ may use ContextEngine)
# openclaw config set agent.memory.enabled true  # Uncomment if your version supports it

# 4. Configure Telegram bot (OpenClaw 2026.3 uses botToken)
openclaw config set channels.telegram.botToken $TELEGRAM_BOT_TOKEN

# 5. Set Telegram log channel (reports go here — skip if not supported)
openclaw config set channels.telegram.log_channel "#proprooster-outreach-log" 2>/dev/null || true

# 6. Skills auto-load from workspace (skills/ subdir). No register command needed.

# 7. Set workspace (so agent finds project files)
openclaw config set agents.defaults.workspace /root/OpenClaw

# 8. Load agent context via shared bootstrap (ICP, playbook, memory)
mkdir -p ~/.openclaw/shared
cp /root/OpenClaw/agent-context/icp.md ~/.openclaw/shared/SHARED_icp.md
cp /root/OpenClaw/agent-context/outreach-playbook.md ~/.openclaw/shared/SHARED_outreach-playbook.md
cp /root/OpenClaw/agent-context/memory-context.md ~/.openclaw/shared/SHARED_memory-context.md

# 9. Verify (OpenClaw 2026.3: config list may have different syntax)
# openclaw config
```

### Verify Telegram connectivity

```bash
openclaw channels status --probe
```

### Verify agent context is loaded

Run these on the VPS to confirm the agent has access to ICP, playbook, and memory:

```bash
# 1. Check shared bootstrap files exist (OpenClaw auto-injects SHARED_*.md)
ls -la ~/.openclaw/shared/
# Should show: SHARED_icp.md, SHARED_memory-context.md, SHARED_outreach-playbook.md

# 2. Check config
openclaw config list

# 3. If gateway is running, restart it so it picks up shared files
pkill -f openclaw-gateway 2>/dev/null || true
nohup openclaw gateway run --bind loopback --port 18789 > /tmp/openclaw-gateway.log 2>&1 &
```

---

## 5. himalaya — Gmail Configuration (IMAP/SMTP)

himalaya is OpenClaw's built-in email CLI skill. Configure it with a Gmail App Password.

### Prerequisites

1. Enable 2FA on the Gmail account
2. Go to: Google Account → Security → App Passwords
3. Generate an App Password for "Mail" → copy the 16-character password
4. Set `GMAIL_APP_PASSWORD` in `~/.openclaw/.env`

### himalaya config (`~/.config/himalaya/config.toml`)

```toml
[accounts.proprooster]
email = "your-followup@gmail.com"
display-name = "Aviv Carmi"
default = true

[accounts.proprooster.incoming]
type = "imap"
host = "imap.gmail.com"
port = 993
encryption = "ssl"
login = "your-followup@gmail.com"
auth.type = "password"
auth.raw = "${GMAIL_APP_PASSWORD}"

[accounts.proprooster.outgoing]
type = "smtp"
host = "smtp.gmail.com"
port = 465
encryption = "ssl"
login = "your-followup@gmail.com"
auth.type = "password"
auth.raw = "${GMAIL_APP_PASSWORD}"
```

### Test

```bash
himalaya list --account proprooster
```

---

## 5b. Datagma (Testing — CSV company list)

For testing without Apollo paid plan, use Datagma with the CSV company list.

1. Get API key at [app.datagma.com](https://app.datagma.com/)
2. Add `DATAGMA_API_KEY` to `~/.openclaw/.env`
3. Register skill: `openclaw skills register skills/datagma-search/SKILL.md`
4. Test with CSV domains:

```bash
# Quick test (first domain from CSV)
bash docs/test-datagma-csv.sh

# Or via agent: datagma-search domain="avenueliving.pt" job_title="Marketing Manager OR Director"
```

CSV: `docs/Developers & real estate agencies - Developers.csv` — extract domains from Website column. Free tier: 90 credits/month (10 per Find People search).

---

## 6. Persistent Gateway (nohup)

### Start gateway

```bash
nohup openclaw gateway run --bind loopback --port 18789 > /tmp/openclaw-gateway.log 2>&1 &
echo "Gateway PID: $!"
```

### Check gateway status

```bash
openclaw gateway status --deep
tail -f /tmp/openclaw-gateway.log
```

### Restart gateway

```bash
pkill -f openclaw-gateway
nohup openclaw gateway run --bind loopback --port 18789 > /tmp/openclaw-gateway.log 2>&1 &
```

### Optional: systemd service (recommended for auto-restart)

Create `/etc/systemd/system/openclaw.service`:

```ini
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/OpenClaw
EnvironmentFile=/root/.openclaw/.env
ExecStart=/usr/local/bin/openclaw gateway run --bind loopback --port 18789
Restart=on-failure
RestartSec=10
StandardOutput=append:/tmp/openclaw-gateway.log
StandardError=append:/tmp/openclaw-gateway.log

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
systemctl daemon-reload
systemctl enable openclaw
systemctl start openclaw
systemctl status openclaw
```

---

## 7. Pre-Flight Checklist (Before First Run)

- [ ] All required env vars set in `~/.openclaw/.env` (including `CALENDLY_BOOKING_URL`)
- [ ] Config in ~/.openclaw/openclaw.json shows model, timezone, workspace
- [ ] `openclaw channels status --probe` returns Telegram OK
- [ ] himalaya can list Gmail inbox: `himalaya list --account proprooster`
- [ ] Instantly inbox warmup: 2 weeks complete
- [ ] Calendly "PropRooster Demo" event type created, link in `CALENDLY_BOOKING_URL`
- [ ] Apollo saved search returns PT real estate leads
- [ ] First run: use PREVIEW MODE (see Phase 4 in proprooster-openclaw-plan.md)

---

*Last updated: 2026-03-16*
