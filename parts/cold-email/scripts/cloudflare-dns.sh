#!/usr/bin/env bash
# Add the two DNS records Warmbly needs, for a domain whose DNS is on
# Cloudflare. Uses a Cloudflare API token the user made with the
# "Edit zone DNS" template for that one zone (saved by save-secret.sh).
#
#   <label>.<domain>     A  <server IP>   DNS only (grey cloud)
#   *.<label>.<domain>   A  <server IP>   DNS only (grey cloud)
#
#   scripts/cloudflare-dns.sh
#   scripts/cloudflare-dns.sh --dry-run   show what would change, change nothing
#
# Never turns on the orange-cloud proxy: Caddy on the server must answer the
# Let's Encrypt check itself.
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need curl jq

DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
API=https://api.cloudflare.com/client/v4
domain="$(state_get domain)"; [ -n "$domain" ] || die "No domain saved."
ip="$(state_get server_ip)";  [ -n "$ip" ] || die "No server IP saved."
read_secret cloudflare-token >/dev/null

cf() {  # cf METHOD PATH [BODY]
  local m="$1" p="$2" b="${3:-}"
  if [ -n "$b" ]; then
    curl -sS -X "$m" "$API$p" -K <(printf 'header = "Authorization: Bearer %s"\n' "$(read_secret cloudflare-token)") \
      -H "Content-Type: application/json" --data-binary "$b"
  else
    curl -sS -X "$m" "$API$p" -K <(printf 'header = "Authorization: Bearer %s"\n' "$(read_secret cloudflare-token)")
  fi
}

z="$(cf GET "/zones?name=$domain")"
[ "$(printf '%s' "$z" | jq -r '.success')" = true ] || die "Cloudflare refused the token: $(printf '%s' "$z" | jq -c '.errors')"
zone="$(printf '%s' "$z" | jq -r '.result[0].id // empty')"
[ -n "$zone" ] || die "This token cannot see the zone $domain. The token must cover that zone."

for name in "$APP_LABEL.$domain" "*.$APP_LABEL.$domain"; do
  existing="$(cf GET "/zones/$zone/dns_records?name=$(printf '%s' "$name" | jq -sRr @uri)")"
  other="$(printf '%s' "$existing" | jq -r '[.result[] | select(.type!="A")] | map(.type + " " + .content) | join(", ")')"
  [ -n "$other" ] && warn "$name also has: $other. An AAAA or CNAME there can break HTTPS. Show the user and ask before removing it."
  rec="$(printf '%s' "$existing" | jq -c '[.result[] | select(.type=="A")][0] // empty')"
  body="$(jq -n --arg n "$name" --arg ip "$ip" '{type:"A", name:$n, content:$ip, ttl:300, proxied:false, comment:"Warmbly (warmbly-hetzner-kit)"}')"
  if [ -z "$rec" ]; then
    if [ "$DRY" = 1 ]; then say "DRY RUN: would add A $name -> $ip (DNS only)"; continue; fi
    r="$(cf POST "/zones/$zone/dns_records" "$body")"
    [ "$(printf '%s' "$r" | jq -r .success)" = true ] || die "Adding $name failed: $(printf '%s' "$r" | jq -c .errors)"
    say "Added A $name -> $ip (DNS only)"
  elif [ "$(printf '%s' "$rec" | jq -r .content)" = "$ip" ] && [ "$(printf '%s' "$rec" | jq -r .proxied)" = false ]; then
    say "Already correct: A $name -> $ip (DNS only)"
  else
    if [ "$DRY" = 1 ]; then say "DRY RUN: would change A $name from $(printf '%s' "$rec" | jq -r .content) to $ip, DNS only"; continue; fi
    r="$(cf PATCH "/zones/$zone/dns_records/$(printf '%s' "$rec" | jq -r .id)" "$body")"
    [ "$(printf '%s' "$r" | jq -r .success)" = true ] || die "Changing $name failed: $(printf '%s' "$r" | jq -c .errors)"
    say "Changed A $name -> $ip (DNS only)"
  fi
done
