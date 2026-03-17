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

# Create himalaya config
mkdir -p ~/.config/himalaya
cat > ~/.config/himalaya/config.toml << EOF
[accounts.proprooster]
email = "$GMAIL"
display-name = "PropRooster"
default = true

[accounts.proprooster.incoming]
type = "imap"
host = "imap.gmail.com"
port = 993
encryption = "ssl"
login = "$GMAIL"
auth.type = "password"
auth.raw = "\${GMAIL_APP_PASSWORD}"

[accounts.proprooster.outgoing]
type = "smtp"
host = "smtp.gmail.com"
port = 465
encryption = "ssl"
login = "$GMAIL"
auth.type = "password"
auth.raw = "\${GMAIL_APP_PASSWORD}"
EOF

echo "Config written to ~/.config/himalaya/config.toml"
echo ""
echo "Ensure GMAIL_APP_PASSWORD is in ~/.openclaw/.env (it's loaded by the gateway)."
echo "Then restart: systemctl --user restart openclaw-gateway"
echo ""
echo "Test: GMAIL_APP_PASSWORD=\$(grep GMAIL_APP_PASSWORD ~/.openclaw/.env | cut -d= -f2-) himalaya list --account proprooster"
