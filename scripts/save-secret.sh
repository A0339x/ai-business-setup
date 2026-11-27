#!/usr/bin/env bash
# Save a key or token the person copied, straight from the Mac clipboard to a
# private file. The value never appears in chat or in any log. The clipboard
# is cleared afterward.
#
#   bash scripts/save-secret.sh <name>        for example: treg-token
#   bash scripts/save-secret.sh --list        list saved names (never values)
#
# The person clicks the site's Copy button first. Then Claude runs this.
# Files go to ~/.config/ai-business-setup/secrets/<name>, readable only by
# the person's own Mac account. Never cat these files.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

if [ "${1:-}" = "--list" ]; then
  [ -d "$SECRETS_DIR" ] || { say "no secrets saved"; exit 0; }
  ls -1 "$SECRETS_DIR"
  exit 0
fi

name="${1:-}"
printf '%s' "$name" | grep -Eq '^[a-z0-9][a-z0-9-]{1,40}$' \
  || die "usage: save-secret.sh <name>, using lowercase letters, digits and dashes, for example treg-token"

need pbpaste pbcopy
value="$(pbpaste | tr -d ' \r\n\t')"
[ -n "$value" ] || die "The clipboard is empty. Ask the person to click Copy again. Nothing was saved."
[ "${#value}" -ge 16 ] || die "The clipboard holds something too short to be a key (${#value} characters). Ask the person to click Copy again. Nothing was saved."
case "$value" in
  http://*|https://*) die "The clipboard holds a web address, not a key. Ask the person to click Copy on the key itself. Nothing was saved." ;;
esac

ensure_setup_dir
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"
dest="$SECRETS_DIR/$name"
( umask 077; printf '%s\n' "$value" > "$dest" )
chmod 600 "$dest"
pbcopy < /dev/null
say "Saved $name to $dest (${#value} characters). Clipboard cleared."
