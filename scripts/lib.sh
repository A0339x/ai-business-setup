#!/usr/bin/env bash
# Shared helpers. Every script in scripts/ sources this file.
# Written for the bash that ships with macOS (3.2): no associative arrays,
# no mapfile, no ${var,,}.

KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../kit.conf
. "$KIT_ROOT/kit.conf"

STATE_FILE="$KIT_DIR/state.json"

say()  { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die()  { printf 'STOP: %s\n' "$*" >&2; exit 1; }

need() {
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "'$c' is not installed. Run scripts/preflight.sh."
  done
}

ensure_kit_dir() {
  mkdir -p "$KIT_DIR"
  chmod 700 "$KIT_DIR"
  [ -f "$STATE_FILE" ] || { printf '{}\n' > "$STATE_FILE"; chmod 600 "$STATE_FILE"; }
}

# Read one top-level value from state.json. Prints nothing if unset.
state_get() {
  [ -f "$STATE_FILE" ] || return 0
  jq -r --arg k "$1" '.[$k] // empty | if type=="array" or type=="object" then tojson else . end' "$STATE_FILE"
}

# Set one top-level string value in state.json.
state_set() {
  ensure_kit_dir
  local tmp
  tmp="$(mktemp "$KIT_DIR/.state.XXXXXX")"
  jq --arg k "$1" --arg v "$2" '.[$k]=$v | .updated_at=(now|todate)' "$STATE_FILE" > "$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$STATE_FILE"
}

# Read a secret file from the kit folder. Never echo the result.
secret_path() { printf '%s/%s' "$KIT_DIR" "$1"; }
read_secret() {
  local f
  f="$(secret_path "$1")"
  [ -s "$f" ] || die "Missing $f. See RUNBOOK.md for how to save it."
  tr -d ' \r\n' < "$f"
}

# The app's base host, such as warmbly.example.com
app_host() {
  local d
  d="$(state_get domain)"
  [ -n "$d" ] || die "No domain saved yet. Run: scripts/state.sh set domain <your-domain>"
  printf '%s.%s' "$APP_LABEL" "$d"
}

# The seven names the bundled Caddy serves under the app host.
app_names() {
  local h
  h="$(app_host)"
  printf '%s\n' "app.$h" "api.$h" "admin.$h" "ws.$h" "track.$h" "forms.$h" "portal.$h"
}

ssh_run() {
  ssh -o BatchMode=yes -o ConnectTimeout=15 "$SSH_HOST_ALIAS" "$@"
}
