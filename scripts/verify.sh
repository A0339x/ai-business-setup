#!/usr/bin/env bash
# Check the finished setup from this Mac: server, containers, HTTPS on all
# seven addresses, key backup present, mailboxes connected and warming.
# Read-only.
#
#   scripts/verify.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

host="$(app_host)"
fail=0

say "== Server"
ssh_run 'hostname; uptime -p; df -h / | tail -1' || { say "Cannot reach the server over SSH."; exit 1; }
ssh_run "sshd -T | grep -E '^passwordauthentication'"

say "== HTTPS"
for n in $(app_names); do
  code="$(curl -sS -o /dev/null -m 15 -w '%{http_code}' "https://$n/" 2>/dev/null || true)"
  printf '%-45s %s\n' "https://$n" "$code"
  if [ "$code" = 000 ]; then fail=1; fi
done
expiry="$(echo | openssl s_client -connect "app.$host:443" -servername "app.$host" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2 || true)"
say "Certificate for app.$host valid until: ${expiry:-unknown}"

say "== Key backup on this Mac"
if [ -s "$KIT_DIR/warmbly-keys-backup.txt" ]; then
  say "present: $KIT_DIR/warmbly-keys-backup.txt ($(stat -f '%Sp' "$KIT_DIR/warmbly-keys-backup.txt"))"
else
  say "MISSING: $KIT_DIR/warmbly-keys-backup.txt"; fail=1
fi

say "== Warmbly"
ssh_run 'install -d -m 700 /root/warmbly-kit'
scp -q "$KIT_ROOT/scripts/remote/status.sh" "$SSH_HOST_ALIAS:/root/warmbly-kit/status.sh"
ssh_run "bash /root/warmbly-kit/status.sh '$WARMBLY_DIR'"

if [ "$fail" = 0 ]; then
  say "VERIFY_OK"
else
  say "VERIFY_FOUND_PROBLEMS"; exit 1
fi
