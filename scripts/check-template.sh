#!/usr/bin/env bash
# Check the daily operations template file and unpack a reading copy.
#
# The template is not in this repo. The person gets the file
# "AI Bot System Template.zip" from the person who shared this folder with them.
#
#   bash scripts/check-template.sh                 look in ~/Downloads
#   bash scripts/check-template.sh "<path to zip>" check that file
#
# It stops unless the file's sha256 matches the one below exactly.
# On a match it unpacks a copy to ~/.config/ai-business-setup/daily-ops/template/
# so Claude can read it, and prints the paths. The zip itself stays where it is,
# so the person can upload it to Grok.
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need shasum unzip

EXPECTED_SHA256=27dd44874a668ef8f9e974db72efe9ce1c31c37fa0d9fca033406a0d72815897
FILE_NAME="AI Bot System Template.zip"

sha_of() { shasum -a 256 "$1" | awk '{print $1}'; }

zip_path="${1:-}"
if [ -z "$zip_path" ]; then
  if [ -f "$HOME/Downloads/$FILE_NAME" ]; then
    zip_path="$HOME/Downloads/$FILE_NAME"
  else
    # Browsers rename repeat downloads, for example "AI Bot System Template (1).zip".
    for f in "$HOME/Downloads"/*emplate*.zip; do
      [ -f "$f" ] || continue
      if [ "$(sha_of "$f")" = "$EXPECTED_SHA256" ]; then zip_path="$f"; break; fi
    done
  fi
fi

[ -n "$zip_path" ] || die "No template file found in ~/Downloads. Ask the person to save \"$FILE_NAME\" there, or to tell you where it is."
[ -f "$zip_path" ] || die "No file at: $zip_path"

actual="$(sha_of "$zip_path")"
if [ "$actual" != "$EXPECTED_SHA256" ]; then
  say "FILE: $zip_path"
  say "EXPECTED sha256: $EXPECTED_SHA256"
  say "ACTUAL   sha256: $actual"
  die "This file is not the expected template. Do not use it. Stop the daily operations part and tell the person."
fi

# Refuse any entry that would land outside the target folder.
if unzip -Z1 "$zip_path" | grep -Eq '(^/|(^|/)\.\.(/|$))'; then
  die "The zip holds an unsafe path. Do not use it."
fi

dest="$SETUP_DIR/daily-ops/template"
ensure_setup_dir
mkdir -p "$SETUP_DIR/daily-ops"
chmod 700 "$SETUP_DIR/daily-ops"
rm -rf "$dest"
mkdir -p "$dest"
unzip -q "$zip_path" -d "$dest"

# The zip has one top folder. Find it, so later steps can name files inside it.
top="$(find "$dest" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
[ -n "$top" ] && [ -f "$top/README.md" ] || die "The zip unpacked, but its README.md is missing. Do not use it."

say "TEMPLATE_OK"
say "zip:    $zip_path"
say "folder: $top"
