#!/usr/bin/env bash
# Runs ON THE SERVER. Waits up to about 4 minutes for every Warmbly container
# to be up, and for each one with a health check to report healthy.
# Usage: wait-healthy.sh <warmbly-dir>
set -euo pipefail
cd "${1:?warmbly dir}"
for _ in $(seq 1 48); do
  sleep 5
  bad="$(docker compose ps -a --format '{{.Service}} {{.Status}}' | grep -c -i -E 'unhealthy|restarting|starting|exited|created' || true)"
  if [ "$bad" = 0 ] && docker compose ps --format '{{.Service}} {{.Status}}' | grep -q '^backend .*(healthy)'; then
    docker compose ps --format '{{.Service}}	{{.Image}}	{{.Status}}'
    echo "ALL_HEALTHY"
    exit 0
  fi
done
docker compose ps -a --format '{{.Service}}	{{.Image}}	{{.Status}}'
echo "--- last backend log lines (long values hidden)"
docker compose logs backend --tail 30 2>&1 | grep -v 'Error reporting is not configured' \
  | sed -E 's/[A-Za-z0-9+\/=_-]{32,}/[hidden]/g' | tail -15
echo "NOT_HEALTHY"
exit 1
