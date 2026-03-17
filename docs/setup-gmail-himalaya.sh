#!/usr/bin/env bash
# PropRooster — Gmail + himalaya setup for OpenClaw
# Run on the VPS. Prerequisites: 2FA enabled on Gmail, App Password created.
# Usage: GMAIL_ADDRESS="your-work@gmail.com" bash setup-gmail-himalaya.sh

set -euo pipefail

GMAIL="${GMAIL_ADDRESS:-}"
if [ -z "$GMAIL" ]; then
  echo "Usage: GMAIL_ADDRESS='your-work@gmail.com' bash setup-gmail-himalaya.sh"
  echo ""
  echo "Before running:"
  echo "1. Enable 2FA on the Gmail account"
  echo "2. Create App Password: Google Account → Security → App Passwords → Mail"
  echo "3. Add to ~/.openclaw/.env: GMAIL_APP_PASSWORD=xxxx xxxx xxxx xxxx"
  exit 1
fi

# Install himalaya if missing
if ! command -v himalaya &>/dev/null; then
  echo "Installing himalaya..."
  curl -sSL https://raw.githubusercontent.com/pimalaya/himalaya/master/install.sh | PREFIX=~/.local sh
  export PATH="$HOME/.local/bin:$PATH"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

himalaya --version || true

# Create himalaya config (pimalaya format - backend.type, not incoming/outgoing)
mkdir -p ~/.config/himalaya
cat > ~/.config/himalaya/config.toml << 'CONFIGEOF'
[accounts.proprooster]
email = "EMAIL_PLACEHOLDER"
display-name = "PropRooster"
default = true

# IMAP backend (pimalaya uses backend.* not incoming)
backend.type = "imap"
backend.host = "imap.gmail.com"
backend.port = 993
backend.encryption.type = "tls"
backend.login = "EMAIL_PLACEHOLDER"
backend.auth.type = "password"
backend.auth.cmd = "grep GMAIL_APP_PASSWORD ~/.openclaw/.env | cut -d= -f2-"

# SMTP backend for sending
message.send.backend.type = "smtp"
message.send.backend.host = "smtp.gmail.com"
message.send.backend.port = 465
message.send.backend.encryption.type = "tls"
message.send.backend.login = "EMAIL_PLACEHOLDER"
message.send.backend.auth.type = "password"
message.send.backend.auth.cmd = "grep GMAIL_APP_PASSWORD ~/.openclaw/.env | cut -d= -f2-"
CONFIGEOF

# Replace placeholder with actual email
sed -i "s/EMAIL_PLACEHOLDER/$GMAIL/g" ~/.config/himalaya/config.toml

echo "Config written to ~/.config/himalaya/config.toml"
echo ""
echo "Ensure GMAIL_APP_PASSWORD is in ~/.openclaw/.env"
echo "Then restart: systemctl --user restart openclaw-gateway"
echo ""
echo "Test: himalaya envelope list --account proprooster"
