#!/usr/bin/env bash
# One-time VPS provisioning for a fresh Hetzner Ubuntu 24.04 box.
# Run as root:  ssh root@<vps-ip>  then  bash provision.sh
# Idempotent-ish: safe to re-run, but review before doing so.
set -euo pipefail

DEPLOY_USER="deploy"
APP_DIR="/opt/adwear"

echo ">>> System update + base packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg ufw fail2ban unattended-upgrades rsync

echo ">>> Automatic security updates"
dpkg-reconfigure -f noninteractive unattended-upgrades

echo ">>> Docker Engine + compose plugin (official repo)"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ">>> Deploy user (SSH-key login only)"
if ! id "$DEPLOY_USER" &>/dev/null; then
  adduser --disabled-password --gecos "" "$DEPLOY_USER"
fi
usermod -aG docker "$DEPLOY_USER"
install -d -m 0700 -o "$DEPLOY_USER" -g "$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh"
echo ">>> Paste the PUBLIC key for the GitHub Actions deploy key, then Ctrl-D:"
cat >> "/home/$DEPLOY_USER/.ssh/authorized_keys"
chown "$DEPLOY_USER:$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh/authorized_keys"
chmod 600 "/home/$DEPLOY_USER/.ssh/authorized_keys"

echo ">>> Harden SSH (no root login, no passwords)"
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh || systemctl restart sshd

echo ">>> Firewall (SSH + HTTP + HTTPS only)"
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo ">>> App directory layout"
install -d -o "$DEPLOY_USER" -g "$DEPLOY_USER" \
  "$APP_DIR" \
  "$APP_DIR/custom/modules/category_migrator" \
  "$APP_DIR/custom/modules/malfini_api" \
  "$APP_DIR/custom/themes/adwear" \
  "$APP_DIR/backups"

cat <<EOF

============================================================
Provisioning done. Next steps (as the deploy user):

  1. Copy deploy/docker-compose.yml, deploy/Caddyfile into $APP_DIR/
  2. Copy deploy/.env.prod.example -> $APP_DIR/.env and fill it in
  3. Log in to GHCR once so the VPS can pull the private image:
       echo <GHCR_READ_PAT> | docker login ghcr.io -u <github-user> --password-stdin
  4. Point DNS: A record  www.adwear.sk -> this server's IP  (and adwear.sk)
  5. Follow "First install" in deploy/README.md
============================================================
EOF
