#!/usr/bin/env bash
# Check that all seven Warmbly addresses point at the server, as seen by two
# public DNS resolvers. Install only after this passes.
#
#   scripts/check-dns.sh          check once
#   scripts/check-dns.sh --wait   check every 30 seconds for up to 30 minutes
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need dig

ip="$(state_get server_ip)"; [ -n "$ip" ] || die "No server IP saved."
wait=0; [ "${1:-}" = "--wait" ] && wait=1

check_once() {
  local bad=0 n r got
  for n in $(app_names); do
    for r in 1.1.1.1 8.8.8.8; do
      got="$(dig +short +time=3 +tries=1 A "$n" "@$r" | grep -E '^[0-9.]+$' | sort | tr '\n' ' ' | sed 's/ $//')"
      if [ "$got" != "$ip" ]; then
        printf 'not yet  %-40s via %-8s got: %s\n' "$n" "$r" "${got:-nothing}"
        bad=1
      fi
    done
  done
  return $bad
}

if [ "$wait" = 0 ]; then
  check_once && say "All 7 addresses point at $ip."
  exit $?
fi
for _ in $(seq 1 60); do
  if check_once; then say "All 7 addresses point at $ip."; exit 0; fi
  say "-- waiting 30 seconds"
  sleep 30
done
die "DNS still does not point at $ip after 30 minutes. Re-check the two records."
