#!/usr/bin/env bash
# Check that this Mac has the tools the kit needs.
#
#   scripts/preflight.sh            check only, change nothing
#   scripts/preflight.sh --install  install jq with Homebrew (ask the user first)
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$KIT_ROOT/kit.conf"

install=0
[ "${1:-}" = "--install" ] && install=1

[ "$(uname -s)" = "Darwin" ] || echo "WARNING: this kit was written for macOS. Other systems may need small changes."

missing=""
for c in curl ssh scp ssh-keygen dig pbpaste pbcopy jq; do
  if command -v "$c" >/dev/null 2>&1; then
    printf 'ok       %s\n' "$c"
  else
    printf 'MISSING  %s\n' "$c"
    missing="$missing $c"
  fi
done

if [ -n "$missing" ]; then
  case "$missing" in
    *jq*)
      if [ "$install" = 1 ]; then
        command -v brew >/dev/null 2>&1 || { echo "STOP: Homebrew is not installed. See https://brew.sh"; exit 1; }
        brew install jq
      else
        echo
        echo "jq is missing. Ask the user, then run: scripts/preflight.sh --install"
        if ! command -v brew >/dev/null 2>&1; then
          echo "Homebrew is also missing. The user installs it from https://brew.sh first."
        fi
        exit 1
      fi ;;
  esac
  for c in $missing; do
    [ "$c" = jq ] && continue
    echo "STOP: $c is missing. It ships with macOS, so this Mac may need Xcode command line tools: xcode-select --install"
    exit 1
  done
fi

mkdir -p "$KIT_DIR"
chmod 700 "$KIT_DIR"
[ -f "$KIT_DIR/state.json" ] || { printf '{}\n' > "$KIT_DIR/state.json"; chmod 600 "$KIT_DIR/state.json"; }
echo
echo "Kit folder ready: $KIT_DIR (only you can read it)"
