#!/usr/bin/env bash
# Runs ON THE SERVER. Read-only health report. Prints no secret values.
# Usage: status.sh <warmbly-dir>
set -uo pipefail
cd "${1:?warmbly dir}" || exit 1

echo "== Containers"
docker compose ps -a --format '{{.Service}}	{{.Image}}	{{.Status}}'

echo "== Settings (names and safe values only)"
grep -E '^(WARMBLY_TAG|DISABLE_REGISTRATION|MAIL_TRANSPORT)=' .env
for k in GEODB_PATH EMAIL_NAME; do
  if grep -q "^$k=" .env; then echo "$k is set"; else echo "$k is MISSING (backend will not start)"; fi
done
ls -l .env keys-backup.txt 2>/dev/null | awk '{print $1, $NF}'

psql_q() {
  docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -X -A -F " | " -P footer=off -c "$0"' "$1"
}

echo "== Mailboxes per domain (total | active | active and warmup not paused)"
psql_q "select split_part(email,'@',2) as domain, count(*) as total,
          count(*) filter (where status='active') as active,
          count(*) filter (where status='active' and warmup_paused_at is null) as warming
        from email_accounts group by 1 order by 1;" \
  || echo "(query failed: the database layout may have changed; check the Accounts page instead)"

echo "== Warmup sends, today and yesterday (UTC)"
psql_q "select a.email, coalesce(sum(s.emails_sent),0) as sent, coalesce(sum(s.emails_replied),0) as replied
        from email_accounts a
        left join warmup_statistics s on s.email_account_id=a.id and s.date >= current_date - 1
        group by 1 order by 1;" \
  || echo "(query failed: check the Accounts page instead)"
echo "(Zeros are normal on day one. New mailboxes send their first warmup emails during the next working hours.)"
