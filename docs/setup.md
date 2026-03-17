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
| `INSTANTLY_API_KEY` | Instantly campaign API key | app.instantly.ai → Settings → API |
| `CALCOM_API_KEY` | Cal.com v1 API key | app.cal.com → Settings → Developer → API Keys |
| `GMAIL_APP_PASSWORD` | Gmail App Password for himalaya IMAP/SMTP | Google Account → Security → App Passwords |

### `.env` template

```bash
# ~/.openclaw/.env
ANTHROPIC_API_KEY=sk-ant-...
TELEGRAM_BOT_TOKEN=...
APOLLO_API_KEY=...
INSTANTLY_API_KEY=...
CALCOM_API_KEY=...
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
# 1. Set agent model (Claude Sonnet minimum — do not downgrade)
openclaw config set agent.model claude-sonnet-4-6

# 2. Set timezone
openclaw config set agent.timezone Europe/Lisbon

# 3. Enable persistent memory (critical — do before first run)
openclaw config set agent.memory.enabled true

# 4. Configure Telegram bot
openclaw config set channels.telegram.token $TELEGRAM_BOT_TOKEN

# 5. Set Telegram log channel (reports go here — not to bot chat)
openclaw config set channels.telegram.log_channel "#proprooster-outreach-log"

# 6. Load agent context files as system prompt injections
openclaw config set agent.context.files "agent-context/icp.md,agent-context/outreach-playbook.md,agent-context/memory-context.md"

# 7. Register custom skills
openclaw skills register skills/apollo-search/SKILL.md
openclaw skills register skills/instantly-campaign/SKILL.md
openclaw skills register skills/calcom-booking/SKILL.md

# 8. Verify full config
openclaw config list
```

### Verify Telegram connectivity

```bash
openclaw channels status --probe
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

- [ ] All 6 env vars set in `~/.openclaw/.env`
- [ ] `openclaw config list` shows correct model, timezone, memory enabled
- [ ] `openclaw channels status --probe` returns Telegram OK
- [ ] himalaya can list Gmail inbox: `himalaya list --account proprooster`
- [ ] Instantly inbox warmup: 2 weeks complete
- [ ] Cal.com "PropRooster Demo" event type created and tested
- [ ] Apollo saved search returns PT real estate leads
- [ ] First run: use PREVIEW MODE (see Phase 4 in proprooster-openclaw-plan.md)

---

*Last updated: 2026-03-16*
