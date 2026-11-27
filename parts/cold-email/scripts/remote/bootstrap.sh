#!/usr/bin/env bash
# Runs ON THE SERVER as root (sent over SSH by scripts/bootstrap-server.sh).
# 1. SSH accepts keys only (no passwords).
# 2. System updates.
# 3. Docker from Docker's own apt repository.
# Safe to run more than once.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "== SSH: keys only"
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\n' > /etc/ssh/sshd_config.d/00-keys-only.conf
sshd -t
systemctl reload ssh
sshd -T | grep -E '^(passwordauthentication|kbdinteractiveauthentication) '

echo "== System updates"
apt-get update -qq
apt-get -y -qq -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold upgrade >/dev/null
apt-get install -y -qq ca-certificates curl >/dev/null
systemctl is-enabled unattended-upgrades >/dev/null 2>&1 && echo "automatic security updates: on"

echo "== Docker"
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "Docker is already installed."
else
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  # shellcheck disable=SC1091
  codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $codename stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null
fi
docker --version
docker compose version

if [ -f /var/run/reboot-required ]; then
  echo "REBOOT_REQUIRED"
fi
