#!/usr/bin/env bash
# Runs ON THE SERVER as root (called by scripts/install-warmbly.sh).
# Verifies Warmbly's installer, runs it pinned to one release with the bundled
# Caddy for HTTPS, applies the .env fixes, and waits for a healthy stack.
#
# Usage: install.sh <warmbly-dir> <version> <host> <installer-sha256> <email-name>
set -euo pipefail
dir="${1:?}"; version="${2:?}"; host="${3:?}"; sha="${4:?}"; email_name="${5:-Warmbly}"
here="$(cd "$(dirname "$0")" && pwd)"
installer=/root/warmbly-install.sh
log=/root/warmbly-install.log

echo "== Checking the installer's sha256"
echo "$sha  $installer" | sha256sum -c -

if [ -f "$dir/.warmbly-install" ]; then
  echo "== Warmbly is already installed in $dir. Skipping the installer."
else
  echo "== Running Warmbly's installer for $version (takes a few minutes)"
  umask 077
  set +e
  sh "$installer" --yes --no-color --host "$host" --tls caddy --version "$version" > "$log" 2>&1
  rc=$?
  set -e
  echo "installer exit code: $rc"
  # Show progress lines, but never lines that could hold a key, a token or the claim link.
  grep -v -i -E 'key|secret|token|password|hash|https?://' "$log" | grep -v '^[[:space:]]*$' | tail -30 || true
  [ -f "$dir/.env" ] || { echo "STOP: the installer did not write $dir/.env. Full log: $log (holds secrets; do not print it whole)"; exit 1; }
  if [ "$rc" != 0 ]; then
    echo "A non-zero exit here is expected when the backend cannot start because of the .env bug. Applying the fix next."
  fi
fi

echo "== .env fixes"
fix_out="$(bash "$here/env-fixes.sh" "$dir" "$email_name")"
echo "$fix_out" | grep -v '^CHANGED$' || true

echo "== Starting the stack"
cd "$dir"
docker compose up -d 2>&1 | tail -3
bash "$here/wait-healthy.sh" "$dir"

echo "== Settings worth knowing (values hidden)"
grep -E '^(WARMBLY_TAG|DISABLE_REGISTRATION|MAIL_TRANSPORT)=' .env
ls -l .env keys-backup.txt | awk '{print $1, $NF}'

# The install log holds the generated secrets and the claim link. The keys
# are also in keys-backup.txt, so the log is not needed.
rm -f "$log"
echo "INSTALL_OK"
