#!/usr/bin/env bash
# Runs ON THE SERVER. Adds two settings to Warmbly's .env if they are missing.
#
# Why: Warmbly's install.sh (checked through v0.8.4) does not write GEODB_PATH
# or EMAIL_NAME, but the backend refuses to start without both. The log shows
#   config GEODB_PATH not found (env: GEODB_PATH, aws: geodb_path)
#   config EMAIL_NAME not found (env: EMAIL_NAME, aws: email/name)
# The GeoIP file itself is optional; the setting only has to exist.
#
# Usage: env-fixes.sh <warmbly-dir> <email-name>
# Prints CHANGED if it added anything, so the caller knows to restart.
set -euo pipefail
dir="${1:?warmbly dir}"
email_name="${2:-Warmbly}"
env="$dir/.env"
[ -f "$env" ] || { echo "No $env yet"; exit 1; }

changed=0
add_if_missing() {
  if ! grep -q "^$1=" "$env"; then
    # Make sure the file ends with a newline before appending.
    [ -z "$(tail -c1 "$env")" ] || printf '\n' >> "$env"
    printf '%s=%s\n' "$1" "$2" >> "$env"
    echo "added $1"
    changed=1
  else
    echo "present $1"
  fi
}

add_if_missing GEODB_PATH /app/data/GeoLite2-City.mmdb
add_if_missing EMAIL_NAME "$email_name"
chmod 600 "$env"
[ "$changed" = 1 ] && echo CHANGED
exit 0
