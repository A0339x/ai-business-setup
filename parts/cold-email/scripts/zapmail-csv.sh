#!/usr/bin/env bash
# Handle Zapmail files without ever printing a password.
#
#   scripts/zapmail-csv.sh upload-file   make the name list Zapmail's "Bulk Upload"
#                                        takes, from the senders saved in state.json,
#                                        at ~/Desktop/zapmail-mailboxes-upload.csv
#   scripts/zapmail-csv.sh stash [file]  move Zapmail's "SMTP IMAP (.csv)" export
#                                        (newest match in ~/Downloads if no file given)
#                                        into ~/.config/warmbly-kit/ with owner-only access
#   scripts/zapmail-csv.sh stage         copy it to ~/Desktop/warmbly-import.csv for
#                                        the Warmbly upload (keep it until the import ends)
#   scripts/zapmail-csv.sh unstage       delete the Desktop copy
#   scripts/zapmail-csv.sh emails        list the addresses in the export
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need jq

store="$KIT_DIR/zapmail-mailboxes.csv"
staged="$HOME/Desktop/warmbly-import.csv"

is_export() { head -1 "$1" | grep -Eqi 'imap password|smtp password|app password'; }

case "${1:-}" in
  upload-file)
    senders="$(state_get senders)"
    [ -n "$senders" ] || die "No senders saved. Save them first with: scripts/state.sh set-json senders '[{\"first\":..,\"last\":..,\"username\":..,\"domain\":..}]'"
    n="$(printf '%s' "$senders" | jq 'length')"
    over="$(printf '%s' "$senders" | jq -r 'group_by(.domain) | map(select(length>5) | .[0].domain) | join(", ")')"
    [ -z "$over" ] || die "Zapmail allows at most 5 mailboxes per domain. Too many on: $over"
    out="$HOME/Desktop/zapmail-mailboxes-upload.csv"
    {
      printf 'First Name,Last Name,Username,Domain Name\n'
      printf '%s' "$senders" | jq -r '.[] | [.first, .last, .username, .domain] | @csv' | tr -d '"'
    } > "$out"
    say "Wrote $out ($n mailboxes). It holds names only, no passwords."
    ;;

  stash)
    src="${2:-}"
    if [ -z "$src" ]; then
      while IFS= read -r f; do
        if is_export "$f"; then src="$f"; break; fi
      done < <(ls -t "$HOME"/Downloads/*.csv 2>/dev/null || true)
    fi
    if [ -z "$src" ] || [ ! -f "$src" ]; then
      die "No Zapmail SMTP IMAP export found in ~/Downloads."
    fi
    is_export "$src" || die "$src does not look like Zapmail's SMTP IMAP export."
    ensure_kit_dir
    ( umask 077; cp "$src" "$store" )
    chmod 600 "$store"
    rm -f "$src"
    say "Moved the export to $store (owner-only). Mailboxes: $(tail -n +2 "$store" | grep -c .)"
    say "Addresses:"
    cut -d, -f1 "$store" | tail -n +2
    ;;

  stage)
    [ -s "$store" ] || die "No export saved yet. Run: scripts/zapmail-csv.sh stash"
    ( umask 077; cp "$store" "$staged" )
    chmod 600 "$staged"
    say "Copied to $staged for the upload. Do NOT delete it until Warmbly says the import finished."
    ;;

  unstage)
    rm -f "$staged"
    say "Deleted $staged. The private copy stays in $store."
    ;;

  emails)
    [ -s "$store" ] || die "No export saved yet."
    cut -d, -f1 "$store" | tail -n +2
    ;;

  *)
    sed -n '2,14p' "$0"; exit 1 ;;
esac
