#!/usr/bin/env bash
# Runs ON THE SERVER. Three steps, called in order by scripts/upgrade-warmbly.sh:
#
#   upgrade.sh <dir> prepare <new-tag>   set WARMBLY_TAG, pull images, print
#                                        "service digest" for each Warmbly image
#   upgrade.sh <dir> apply               start the new images, wait for health
#   upgrade.sh <dir> revert <old-tag>    put the old WARMBLY_TAG back (no restart)
#
# It never re-runs install.sh, so .env is not rewritten and the GEODB_PATH and
# EMAIL_NAME lines stay.
set -euo pipefail
dir="${1:?}"; step="${2:?}"
here="$(cd "$(dirname "$0")" && pwd)"
cd "$dir"

case "$step" in
  prepare)
    new="${3:?new tag}"
    sed -i "s/^WARMBLY_TAG=.*/WARMBLY_TAG=$new/" .env
    grep '^WARMBLY_TAG=' .env
    docker compose pull -q
    prefix="$(grep -E '^WARMBLY_IMAGE_PREFIX=' .env | cut -d= -f2)"
    docker compose config --images | sort -u | while read -r img; do
      case "$img" in
        "$prefix"/*)
          svc="${img#"$prefix"/}"; svc="${svc%%:*}"
          echo "DIGEST $svc $(docker image inspect "$img" --format '{{index .RepoDigests 0}}' | sed 's/.*@//')" ;;
      esac
    done
    ;;
  apply)
    bash "$here/env-fixes.sh" "$dir" Warmbly | grep -v '^CHANGED$' || true
    docker compose up -d 2>&1 | tail -3
    bash "$here/wait-healthy.sh" "$dir"
    echo "--- migration lines from the backend log"
    docker compose logs backend --since 5m 2>&1 | grep -i -E 'migrat' | tail -5 || true
    ;;
  revert)
    old="${3:?old tag}"
    sed -i "s/^WARMBLY_TAG=.*/WARMBLY_TAG=$old/" .env
    grep '^WARMBLY_TAG=' .env
    ;;
  *)
    echo "unknown step: $step"; exit 1 ;;
esac
