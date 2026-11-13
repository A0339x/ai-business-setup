#!/usr/bin/env bash
# Prepare the new server: key-only SSH, updates, Docker. Reboots once if the
# updates need it, then waits for the server to come back.
#
#   scripts/bootstrap-server.sh
#   scripts/bootstrap-server.sh --dry-run   show the server script, run nothing
set -euo pipefail
. "$(dirname "$0")/lib.sh"

remote="$KIT_ROOT/scripts/remote/bootstrap.sh"
if [ "${1:-}" = "--dry-run" ]; then
  say "DRY RUN: would run this on $SSH_HOST_ALIAS as root:"
  cat "$remote"
  exit 0
fi

out="$(ssh_run 'bash -s' < "$remote")"
printf '%s\n' "$out" | grep -v '^REBOOT_REQUIRED$' || true

if grep -q '^REBOOT_REQUIRED$' <<<"$out"; then
  say "== Updates need a reboot. Rebooting now."
  ssh_run 'systemctl reboot' || true
  sleep 20
  i=0
  until ssh_run true >/dev/null 2>&1; do
    i=$((i+1)); [ $i -gt 40 ] && die "The server did not come back within about 4 minutes of the reboot."
    sleep 6
  done
  say "Server is back."
fi

# Prove password sign-in is off.
ssh_run "sshd -T | grep -q '^passwordauthentication no'" || die "Password sign-in is still on."
ssh_run 'docker compose version' >/dev/null || die "Docker Compose is not working."
say "Bootstrap done: key-only SSH, updates applied, Docker installed."
