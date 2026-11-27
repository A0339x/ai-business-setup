#!/usr/bin/env bash
# Shared helpers for the scripts in this folder. Each script sources this file.
# Written for the bash that ships with macOS (3.2): no associative arrays,
# no mapfile, no ${var,,}.

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SETUP_ROOT

# Everything this setup saves on the Mac lives here, outside the repo.
SETUP_DIR="${AI_SETUP_DIR:-$HOME/.config/ai-business-setup}"
STATE_FILE="$SETUP_DIR/state.json"
SECRETS_DIR="$SETUP_DIR/secrets"

# The four parts, in the order they are set up.
ALL_PARTS="daily-ops lead-lists website-check cold-email"

say()  { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die()  { printf 'STOP: %s\n' "$*" >&2; exit 1; }

need() {
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "'$c' is not installed. Run: bash scripts/check-mac.sh"
  done
}

ensure_setup_dir() {
  mkdir -p "$SETUP_DIR"
  chmod 700 "$SETUP_DIR"
  [ -f "$STATE_FILE" ] || { printf '{}\n' > "$STATE_FILE"; chmod 600 "$STATE_FILE"; }
}

is_part() {
  local p
  for p in $ALL_PARTS; do
    [ "$p" = "$1" ] && return 0
  done
  return 1
}

# Write state.json through a temp file, so a crash never leaves half a file.
# Usage: state_jq <jq-args...> '<filter>'
state_jq() {
  ensure_setup_dir
  local tmp
  tmp="$(mktemp "$SETUP_DIR/.state.XXXXXX")"
  if jq "$@" "$STATE_FILE" > "$tmp"; then
    chmod 600 "$tmp"
    mv "$tmp" "$STATE_FILE"
  else
    rm -f "$tmp"
    die "could not update $STATE_FILE"
  fi
}
