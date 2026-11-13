#!/usr/bin/env bash
# Get Warmbly's single-use link that makes the first account the owner, and
# open it in a browser on this Mac. The link is never printed.
#
#   scripts/claim-link.sh                       open in the default browser
#   scripts/claim-link.sh --app "Google Chrome" open in that browser app
#   scripts/claim-link.sh --status              only show whether it is claimed
set -euo pipefail
. "$(dirname "$0")/lib.sh"

ctl() { ssh_run "cd $WARMBLY_DIR && docker compose exec -T backend warmblyctl $*"; }

if [ "${1:-}" = "--status" ]; then
  ctl status 2>/dev/null | sed -E 's#https?://[^ ]*(setup|claim|reset)[^ ]*#[link hidden]#g'
  exit 0
fi

app=""
[ "${1:-}" = "--app" ] && app="${2:?browser app name}"

link="$(ctl setup-link 2>/dev/null | grep -Eo 'https://[^ ]+' | head -1 || true)"
if [ -z "$link" ]; then
  say "No claim link was issued. That usually means an account already exists (the instance is claimed)."
  say "Check with: scripts/claim-link.sh --status"
  exit 1
fi
case "$link" in
  "https://app.$(app_host)/"*) ;;
  *) die "The link points somewhere unexpected. Not opening it." ;;
esac
if [ -n "$app" ]; then open -a "$app" "$link"; else open "$link"; fi
say "Opened the claim page in the browser. The link works once and expires."
