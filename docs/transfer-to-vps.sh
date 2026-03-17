#!/usr/bin/env bash
# PropRooster — Transfer project files to VPS
# Run from your Mac after Hetzner server is provisioned
# Usage: VPS_IP=<your-server-ip> bash transfer-to-vps.sh

set -euo pipefail

if [ -z "${VPS_IP:-}" ]; then
  echo "Usage: VPS_IP=<server-ip> bash transfer-to-vps.sh"
  exit 1
fi

SSH_KEY="$HOME/.ssh/id_ed25519_proprooster"
PROJECT_DIR="$HOME/Desktop/Projects/OpenClaw"
REMOTE_DIR="/root/OpenClaw"

echo "Transferring $PROJECT_DIR → root@$VPS_IP:$REMOTE_DIR"

rsync -avz \
  --exclude='.git' \
  --exclude='.DS_Store' \
  --exclude='*.env' \
  -e "ssh -i $SSH_KEY" \
  "$PROJECT_DIR/" \
  "root@$VPS_IP:$REMOTE_DIR/"

echo ""
echo "Transfer complete."
echo ""
echo "Next steps on the VPS (ssh -i $SSH_KEY root@$VPS_IP):"
echo "  1. cp $REMOTE_DIR/.env.template ~/.openclaw/.env"
echo "  2. nano ~/.openclaw/.env  # fill in API keys"
echo "  3. bash $REMOTE_DIR/docs/configure-openclaw.sh"
echo "  4. bash $REMOTE_DIR/docs/start-gateway.sh"
