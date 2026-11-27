#!/usr/bin/env bash
# Check that this Mac has the small tools this setup's scripts use.
# It changes nothing.
#
#   bash scripts/check-mac.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

[ "$(uname -s)" = "Darwin" ] || warn "this setup was written for macOS. Other systems may need small changes."

missing=""
for c in curl jq shasum unzip pbpaste pbcopy; do
  if command -v "$c" >/dev/null 2>&1; then
    printf 'ok       %s\n' "$c"
  else
    printf 'MISSING  %s\n' "$c"
    missing="$missing $c"
  fi
done

if [ -n "$missing" ]; then
  echo
  case "$missing" in
    *jq*)
      echo "jq is missing. Newer macOS versions include it."
      echo "Ask the person, then install it with Homebrew: brew install jq"
      command -v brew >/dev/null 2>&1 || echo "Homebrew is also missing. The person installs it from https://brew.sh first." ;;
  esac
  exit 1
fi

ensure_setup_dir
echo
echo "Setup folder ready: $SETUP_DIR (only you can read it)"
