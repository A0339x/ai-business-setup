#!/usr/bin/env bash
# Upgrade Warmbly to a newer release, safely.
#
# 1. Back up .env and the database on the server.
# 2. Set WARMBLY_TAG to the new release and pull its images.
# 3. Compare every pulled image's digest with the release's images.json.
#    Any mismatch: put the old tag back and stop. Nothing restarts.
# 4. Start the new images and wait until every container is healthy.
#    The backend runs its database migrations on start.
#
#   scripts/upgrade-warmbly.sh v0.8.5
#   scripts/upgrade-warmbly.sh v0.8.5 --dry-run   show the plan, change nothing
#
# Ask the user before running it for real. Read the release notes first:
# https://github.com/warmbly/warmbly/releases
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need curl jq scp

new="${1:-}"
[ -n "$new" ] || die "usage: upgrade-warmbly.sh <tag, such as v0.8.5> [--dry-run]"
DRY=0; [ "${2:-}" = "--dry-run" ] && DRY=1

manifest="$(curl -fsSL "https://github.com/warmbly/warmbly/releases/download/$new/images.json")" \
  || die "Could not download images.json for $new. Check the tag name."
[ "$(printf '%s' "$manifest" | jq -r .tag)" = "$new" ] || die "images.json does not name $new."

old="$(ssh_run "grep -E '^WARMBLY_TAG=' $WARMBLY_DIR/.env | cut -d= -f2")"
say "Current: $old   New: $new"
if [ "$old" = "$new" ]; then say "Already on $new."; exit 0; fi

if [ "$DRY" = 1 ]; then
  say "DRY RUN. Would: back up .env + database to /root/warmbly-backups/, set WARMBLY_TAG=$new,"
  say "pull, compare digests with images.json for these images:"
  printf '%s' "$manifest" | jq -r '.images | keys[]' | sed 's/^/  /'
  say "then start the new images and wait for health."
  exit 0
fi

ssh_run 'install -d -m 700 /root/warmbly-kit'
scp -q "$KIT_ROOT"/scripts/remote/*.sh "$SSH_HOST_ALIAS:/root/warmbly-kit/"

say "== 1. Backup"
backup_out="$(ssh_run "bash /root/warmbly-kit/backup.sh '$WARMBLY_DIR'")" || true
printf '%s\n' "$backup_out"
grep -q '^BACKUP_OK$' <<<"$backup_out" || die "Backup failed. Nothing changed."

say "== 2. Pull $new"
pulled="$(ssh_run "bash /root/warmbly-kit/upgrade.sh '$WARMBLY_DIR' prepare '$new'")" || {
  ssh_run "bash /root/warmbly-kit/upgrade.sh '$WARMBLY_DIR' revert '$old'"; die "Pull failed. Old tag restored; nothing restarted."; }

say "== 3. Compare digests with images.json"
bad=0; checked=0
while read -r _ svc digest; do
  want="$(printf '%s' "$manifest" | jq -r --arg s "$svc" '.images[$s] // empty')"
  if [ -z "$want" ]; then
    say "  $svc: not listed in images.json (skipped)"
  elif [ "$want" = "$digest" ]; then
    say "  $svc: match"; checked=$((checked+1))
  else
    say "  $svc: MISMATCH (got $digest, want $want)"; bad=1
  fi
done < <(printf '%s\n' "$pulled" | grep '^DIGEST ')
if [ "$bad" = 1 ] || [ "$checked" = 0 ]; then
  ssh_run "bash /root/warmbly-kit/upgrade.sh '$WARMBLY_DIR' revert '$old'"
  die "Digest check failed. Old tag restored; the running version is unchanged."
fi

say "== 4. Start $new"
ssh_run "bash /root/warmbly-kit/upgrade.sh '$WARMBLY_DIR' apply" || die "Not healthy after the upgrade. See RUNBOOK.md, Maintenance, 'If an upgrade goes wrong'."
state_set warmbly_version "$new"
say "Upgraded to $new. Now run scripts/verify.sh and check that every mailbox still shows Warming."
