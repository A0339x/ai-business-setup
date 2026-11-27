#!/usr/bin/env bash
# Save a token the user copied, straight from the Mac clipboard into the kit
# folder. The token never appears in chat or in any log. The clipboard is
# cleared afterward.
#
#   scripts/save-secret.sh hetzner-token
#   scripts/save-secret.sh cloudflare-token
#
# The user clicks the site's Copy button first. Then Claude runs this.
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need pbpaste pbcopy

name="${1:-}"
case "$name" in
  hetzner-token)    pattern='^[A-Za-z0-9]{64}$' ;;
  cloudflare-token) pattern='^[A-Za-z0-9_-]{40,}$' ;;
  *) die "usage: save-secret.sh hetzner-token|cloudflare-token" ;;
esac

ensure_kit_dir
value="$(pbpaste | tr -d ' \r\n\t')"
if ! printf '%s' "$value" | grep -Eq "$pattern"; then
  die "The clipboard does not hold a $name (wrong length or characters). Ask the user to click Copy on the token again. Nothing was saved."
fi

dest="$(secret_path "$name")"
( umask 077; printf '%s\n' "$value" > "$dest" )
chmod 600 "$dest"
pbcopy < /dev/null
say "Saved $name to $dest (${#value} characters). Clipboard cleared."
