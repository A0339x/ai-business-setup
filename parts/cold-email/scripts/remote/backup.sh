#!/usr/bin/env bash
# Runs ON THE SERVER. Saves a copy of Warmbly's .env and a full database dump
# to /root/warmbly-backups/ (owner-only). Run before every upgrade.
# Usage: backup.sh <warmbly-dir>
set -euo pipefail
cd "${1:?warmbly dir}"
ts="$(date -u +%Y%m%dT%H%M%SZ)"
tag="$(grep -E '^WARMBLY_TAG=' .env | cut -d= -f2)"
install -d -m 700 /root/warmbly-backups
cp -p .env "/root/warmbly-backups/env-$tag-$ts"
docker compose exec -T postgres sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc' \
  > "/root/warmbly-backups/db-$tag-$ts.dump"
chmod 600 /root/warmbly-backups/*
[ -s "/root/warmbly-backups/db-$tag-$ts.dump" ] || { echo "STOP: the database dump is empty"; exit 1; }
ls -l "/root/warmbly-backups/env-$tag-$ts" "/root/warmbly-backups/db-$tag-$ts.dump" | awk '{print $5, $NF}'
echo "BACKUP_OK"
