#!/usr/bin/env bash
# Install Warmbly on the server, pinned to WARMBLY_VERSION in kit.conf.
#
# 1. Download install.sh and its .sha256 from the warmbly/warmbly repo at the
#    pinned release tag. Check the file against the published checksum AND the
#    checksum recorded in kit.conf. Stop if either differs.
# 2. Copy it to the server, check it again there, and run it with
#    --yes --host <label>.<domain> --tls caddy --version <pinned>.
# 3. Add GEODB_PATH and EMAIL_NAME to .env if missing, restart, wait for health.
# 4. Copy the two unrecoverable keys to ~/.config/warmbly-kit/ on this Mac.
# 5. Check HTTPS on all seven addresses.
#
#   scripts/install-warmbly.sh
#   scripts/install-warmbly.sh --dry-run   download and check the installer, then
#                                          show the .env and compose file it would
#                                          write on the server, install nothing
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need curl shasum scp

DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
host="$(app_host)"
email_name="$(state_get platform_email_name)"; [ -n "$email_name" ] || email_name="Warmbly"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
raw="https://raw.githubusercontent.com/warmbly/warmbly/$WARMBLY_VERSION/site/public"

say "== Downloading Warmbly's installer for $WARMBLY_VERSION"
curl -fsSL "$raw/install.sh" -o "$work/install.sh"
curl -fsSL "$raw/install.sh.sha256" -o "$work/install.sh.sha256"
got="$(shasum -a 256 "$work/install.sh" | cut -d' ' -f1)"
published="$(cut -d' ' -f1 < "$work/install.sh.sha256")"
[ "$got" = "$published" ] || die "install.sh does not match Warmbly's published checksum. Do not run it."
[ "$got" = "$WARMBLY_INSTALLER_SHA256" ] || die "install.sh matches Warmbly's checksum but not the one in kit.conf. Upstream changed it. Read the new installer before trusting it, then update kit.conf."
say "Installer checksum OK: $got"

say "== Copying kit scripts and the installer to the server"
ssh_run 'install -d -m 700 /root/warmbly-kit'
scp -q "$KIT_ROOT"/scripts/remote/*.sh "$SSH_HOST_ALIAS:/root/warmbly-kit/"
scp -q "$work/install.sh" "$SSH_HOST_ALIAS:/root/warmbly-install.sh"

if [ "$DRY" = 1 ]; then
  say "DRY RUN: the installer would write this (secrets hidden):"
  ssh_run "cd /root && echo '$got  warmbly-install.sh' | sha256sum -c - && sh warmbly-install.sh --dry-run --yes --no-color --host '$host' --tls caddy --version '$WARMBLY_VERSION'" \
    | sed -E -e 's/^([A-Z_]*(KEY|SECRET|TOKEN|PASSWORD|HASH|PRIMARY_DB|REDIS)[A-Z_]*=).*/\1[hidden]/' \
             -e 's#://[^:/@ ]+:[^@ ]+@#://[hidden]@#g'
  exit 0
fi

say "== Installing on the server"
out="$(ssh_run "bash /root/warmbly-kit/install.sh '$WARMBLY_DIR' '$WARMBLY_VERSION' '$host' '$got' '$email_name'")" || {
  printf '%s\n' "$out"; die "The install did not finish. See RUNBOOK.md, Phase 4, known problems."; }
printf '%s\n' "$out"
grep -q '^INSTALL_OK$' <<<"$out" || die "The install did not report success."
state_set warmbly_version "$WARMBLY_VERSION"

say "== Backing up the two unrecoverable keys to this Mac"
ensure_kit_dir
dest="$KIT_DIR/warmbly-keys-backup.txt"
( umask 077; scp -q "$SSH_HOST_ALIAS:$WARMBLY_DIR/keys-backup.txt" "$dest" )
chmod 600 "$dest"
[ -s "$dest" ] || die "The key backup copy is empty."
say "Saved $dest ($(wc -l < "$dest" | tr -d ' ') lines). Contents not shown."

say "== Checking HTTPS (certificates can take a minute or two)"
https_code() {  # prints the HTTP status, or 000 if there is no valid HTTPS
  curl -sS -o /dev/null -m 15 -w '%{http_code}' "https://$1/" 2>/dev/null || true
}
for _ in $(seq 1 12); do
  bad=0
  for n in $(app_names); do
    if [ "$(https_code "$n")" = 000 ]; then bad=1; fi
  done
  if [ "$bad" = 0 ]; then break; fi
  sleep 15
done
for n in $(app_names); do
  printf '%-45s %s\n' "https://$n" "$(https_code "$n")"
done
app_code="$(https_code "app.$host")"
case "$app_code" in
  2??|3??) ;;
  *) die "https://app.$host did not load with a valid certificate (got $app_code). See RUNBOOK.md, Phase 4." ;;
esac
say "Warmbly is running at https://app.$host"
