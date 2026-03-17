#!/usr/bin/env bash
# PropRooster — Hetzner VPS Bootstrap Script
# Run as root on a fresh Ubuntu 22.04 CX11
# Usage: bash vps-bootstrap.sh

set -euo pipefail

echo "=== PropRooster VPS Bootstrap ==="

# 1. System update
apt-get update -qq && apt-get upgrade -y -qq

# 2. Basic hardening
ufw allow 22/tcp
ufw allow 443/tcp
ufw --force enable
echo "Firewall: SSH + HTTPS allowed, all else denied"

# Disable root password login (key-based only)
sed -i 's/^#\?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
systemctl restart ssh
echo "SSH: password auth disabled, key-only"

# 3. Install Node.js (LTS via nodesource)
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs
echo "Node $(node -v) installed"
echo "npm $(npm -v) installed"

# 4. Install OpenClaw
npm install -g openclaw
echo "OpenClaw $(openclaw --version 2>/dev/null || echo 'installed') ready"

# 5. Install himalaya (email CLI)
curl -sSfL https://github.com/soywod/himalaya/releases/latest/download/himalaya-linux.tar.gz \
  | tar -xz -C /usr/local/bin
echo "himalaya $(himalaya --version) installed"

# 6. Create OpenClaw dirs
mkdir -p ~/.openclaw
mkdir -p ~/.config/himalaya

echo ""
echo "=== Bootstrap complete ==="
echo "Next: run configure-openclaw.sh after filling in ~/.openclaw/.env"
