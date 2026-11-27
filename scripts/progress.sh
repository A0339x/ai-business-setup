#!/usr/bin/env bash
# Save and read the setup's progress: ~/.config/ai-business-setup/state.json
# The file holds choices and status only. It never holds a secret.
# It lets a new Claude session pick up where the last one stopped.
#
#   bash scripts/progress.sh show                     print the whole file
#   bash scripts/progress.sh choose <part>...         save the parts the person picked
#                                                     (daily-ops lead-lists website-check
#                                                      cold-email, or: everything)
#   bash scripts/progress.sh next                     print the first chosen part not finished
#   bash scripts/progress.sh start <part>             mark a part as started
#   bash scripts/progress.sh step <part> <step>       record the last step finished in a part
#   bash scripts/progress.sh done <part>              mark a part as finished and checked
#   bash scripts/progress.sh skip <part>              mark a chosen part as skipped
#   bash scripts/progress.sh get <key>                print one saved value
#   bash scripts/progress.sh set <key> <value>        save one text value (not a secret)
#   bash scripts/progress.sh set-json <key> <json>    save a list or object (not a secret)
#   bash scripts/progress.sh reset                    start over (asks the person first)
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need jq
ensure_setup_dir

# Refuse anything that looks like a secret. Secrets go through save-secret.sh.
refuse_secret() {
  local key="$1" value="$2" lower
  lower="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')"
  case "$lower" in
    *token*|*password*|*passwd*|*secret*|*apikey*|*api_key*|*api-key*|*private*)
      die "'$key' looks like a secret. Do not save secrets here. Use: bash scripts/save-secret.sh" ;;
  esac
  case "$value" in
    trg_*|sk-*|xai-*|ghp_*|github_pat_*|nfp_*)
      die "That value looks like a key or token. Nothing was saved. Use: bash scripts/save-secret.sh" ;;
  esac
  if printf '%s' "$value" | grep -Eq '^[A-Za-z0-9_+/=-]{40,}$'; then
    die "That value looks like a key or token. Nothing was saved. Use: bash scripts/save-secret.sh"
  fi
}

check_part() {
  is_part "$1" || die "unknown part '$1'. Parts: $ALL_PARTS"
}

cmd="${1:-show}"
case "$cmd" in
  show)
    jq . "$STATE_FILE" ;;

  choose)
    shift
    [ $# -ge 1 ] || die "usage: progress.sh choose <part>... (or: everything)"
    picked=""
    sync="no"
    for a in "$@"; do
      if [ "$a" = "everything" ]; then
        picked="$ALL_PARTS"; sync="yes"; break
      fi
      check_part "$a"
      picked="$picked $a"
    done
    # Keep the set-up order, whatever order the person named them in.
    ordered=""
    for p in $ALL_PARTS; do
      case " $picked " in *" $p "*) ordered="$ordered $p" ;; esac
    done
    json="$(printf '%s\n' $ordered | jq -R . | jq -s .)"
    state_jq --argjson c "$json" --arg s "$sync" \
      '.chosen=$c | .claude_grok_sync=(if $s=="yes" then "yes" else (.claude_grok_sync // "ask") end)
       | .parts=((.parts // {}) as $old | reduce $c[] as $p ($old; .[$p] = (.[$p] // {status:"not started"})))
       | .updated_at=(now|todate)'
    say "chosen, in set-up order:$ordered" ;;

  next)
    if ! jq -e '(.chosen // []) | length > 0' "$STATE_FILE" >/dev/null; then
      say "nothing chosen yet"; exit 0
    fi
    jq -r '
      [ .chosen[] as $p | select(((.parts[$p].status) // "not started") as $s | $s != "done" and $s != "skipped") | $p ][0]
      // "all chosen parts done"' "$STATE_FILE" ;;

  start)
    [ $# -eq 2 ] || die "usage: progress.sh start <part>"
    check_part "$2"
    state_jq --arg p "$2" '.parts[$p].status="in progress" | .parts[$p].started_at=(.parts[$p].started_at // (now|todate)) | .updated_at=(now|todate)'
    say "$2 started" ;;

  step)
    [ $# -eq 3 ] || die "usage: progress.sh step <part> <step>"
    check_part "$2"
    refuse_secret step "$3"
    state_jq --arg p "$2" --arg s "$3" '.parts[$p].status=(if .parts[$p].status=="done" then "done" else "in progress" end)
      | .parts[$p].last_step=$s | .parts[$p].steps_done=((.parts[$p].steps_done // []) + [$s] | unique) | .updated_at=(now|todate)'
    say "$2: step $3 recorded" ;;

  done)
    [ $# -eq 2 ] || die "usage: progress.sh done <part>"
    check_part "$2"
    state_jq --arg p "$2" '.parts[$p].status="done" | .parts[$p].done_at=(now|todate) | .updated_at=(now|todate)'
    say "$2 recorded as done" ;;

  skip)
    [ $# -eq 2 ] || die "usage: progress.sh skip <part>"
    check_part "$2"
    state_jq --arg p "$2" '.parts[$p].status="skipped" | .updated_at=(now|todate)'
    say "$2 recorded as skipped" ;;

  get)
    [ $# -eq 2 ] || die "usage: progress.sh get <key>"
    jq -r --arg k "$2" '.[$k] // empty | if type=="array" or type=="object" then tojson else . end' "$STATE_FILE" ;;

  set)
    [ $# -eq 3 ] || die "usage: progress.sh set <key> <value>"
    refuse_secret "$2" "$3"
    state_jq --arg k "$2" --arg v "$3" '.[$k]=$v | .updated_at=(now|todate)'
    say "saved $2" ;;

  set-json)
    [ $# -eq 3 ] || die "usage: progress.sh set-json <key> <json>"
    refuse_secret "$2" ""
    printf '%s' "$3" | jq -e . >/dev/null 2>&1 || die "not valid JSON"
    state_jq --arg k "$2" --argjson v "$3" '.[$k]=$v | .updated_at=(now|todate)'
    say "saved $2" ;;

  reset)
    backup="$STATE_FILE.$(date +%Y%m%d%H%M%S).bak"
    cp "$STATE_FILE" "$backup"
    chmod 600 "$backup"
    printf '{}\n' > "$STATE_FILE"
    chmod 600 "$STATE_FILE"
    say "progress cleared. The old file is saved at $backup" ;;

  *)
    die "unknown command: $cmd" ;;
esac
