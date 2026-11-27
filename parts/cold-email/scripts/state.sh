#!/usr/bin/env bash
# Read and write the setup's progress file: ~/.config/warmbly-kit/state.json
# The file holds no secrets. It lets a new Claude session resume mid-setup.
#
#   scripts/state.sh show                 print the whole file
#   scripts/state.sh get <key>            print one value
#   scripts/state.sh set <key> <value>    save one text value
#   scripts/state.sh set-json <key> <json>  save a list or object
#   scripts/state.sh done <phase-number>  record that a phase finished
#   scripts/state.sh next                 print the first phase not finished
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need jq
ensure_kit_dir

cmd="${1:-show}"
case "$cmd" in
  show)
    jq . "$STATE_FILE" ;;
  get)
    [ $# -eq 2 ] || die "usage: state.sh get <key>"
    state_get "$2" ;;
  set)
    [ $# -eq 3 ] || die "usage: state.sh set <key> <value>"
    state_set "$2" "$3"
    say "saved $2" ;;
  set-json)
    [ $# -eq 3 ] || die "usage: state.sh set-json <key> <json>"
    printf '%s' "$3" | jq -e . >/dev/null || die "not valid JSON"
    tmp="$(mktemp "$KIT_DIR/.state.XXXXXX")"
    jq --arg k "$2" --argjson v "$3" '.[$k]=$v | .updated_at=(now|todate)' "$STATE_FILE" > "$tmp"
    chmod 600 "$tmp"; mv "$tmp" "$STATE_FILE"
    say "saved $2" ;;
  done)
    [ $# -eq 2 ] || die "usage: state.sh done <phase-number>"
    tmp="$(mktemp "$KIT_DIR/.state.XXXXXX")"
    jq --arg p "$2" '.phases_done=((.phases_done // []) + [$p] | unique) | .updated_at=(now|todate)' "$STATE_FILE" > "$tmp"
    chmod 600 "$tmp"; mv "$tmp" "$STATE_FILE"
    say "phase $2 recorded as done" ;;
  next)
    for p in 0 1 2 3 4 5 6 7 8; do
      if ! jq -e --arg p "$p" '(.phases_done // []) | index($p)' "$STATE_FILE" >/dev/null; then
        say "$p"; exit 0
      fi
    done
    say "all phases done" ;;
  *)
    die "unknown command: $cmd" ;;
esac
