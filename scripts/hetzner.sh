#!/usr/bin/env bash
# Hetzner Cloud API helper. Uses the token saved by save-secret.sh.
# The token is passed to curl through a private config stream, never as a
# command-line argument, so it does not show up in process lists or logs.
#
#   scripts/hetzner.sh check                 prove the token works
#   scripts/hetzner.sh price                 monthly price of the server + IPv4
#   scripts/hetzner.sh ssh-key               make a dedicated SSH key and upload it
#   scripts/hetzner.sh firewall              create the cloud firewall (22, 80, 443, ping)
#   scripts/hetzner.sh create-server         create the server (COSTS MONEY: ask first)
#   scripts/hetzner.sh wait                  wait until the server answers on SSH
#   scripts/hetzner.sh ssh-config            add "Host warmbly" to ~/.ssh/config
#   scripts/hetzner.sh status                show the server
#
# Add --dry-run after the command to print what would be sent without
# creating anything.
set -euo pipefail
. "$(dirname "$0")/lib.sh"
need curl jq

API=https://api.hetzner.cloud/v1
cmd="${1:-}"
DRY=0
[ "${2:-}" = "--dry-run" ] && DRY=1

token_config() {
  printf 'header = "Authorization: Bearer %s"\n' "$(read_secret hetzner-token)"
}

# api METHOD PATH [JSON_BODY]
api() {
  local method="$1" path="$2" body="${3:-}"
  if [ "$DRY" = 1 ] && [ "$method" = GET ] && [ ! -s "$(secret_path hetzner-token)" ]; then
    say "DRY RUN: no token saved, so lookups return empty lists" >&2
    printf '{"servers":[],"firewalls":[],"ssh_keys":[]}\n'
    return 0
  fi
  if [ "$DRY" = 1 ] && [ "$method" != GET ]; then
    say "DRY RUN: would send $method $API$path" >&2
    [ -n "$body" ] && printf '%s\n' "$body" | jq . >&2
    printf '{"dry_run":true}\n'
    return 0
  fi
  if [ -n "$body" ]; then
    curl -sS -X "$method" "$API$path" -K <(token_config) \
      -H "Content-Type: application/json" --data-binary "$body"
  else
    curl -sS -X "$method" "$API$path" -K <(token_config)
  fi
}

fail_on_error() {
  local resp="$1" what="$2"
  if printf '%s' "$resp" | jq -e '.error' >/dev/null 2>&1; then
    die "$what failed: $(printf '%s' "$resp" | jq -r '.error.code + ": " + .error.message')"
  fi
}

case "$cmd" in
  check|price|ssh-key|firewall|create-server|wait|status)
    [ "$DRY" = 1 ] || read_secret hetzner-token >/dev/null ;;
esac

case "$cmd" in
  check)
    r="$(api GET /servers)"
    fail_on_error "$r" "Token check"
    say "Token works. Servers in this project: $(printf '%s' "$r" | jq '.servers | length')"
    ;;

  price)
    loc="${HETZNER_LOCATIONS%% *}"
    r="$(api GET /pricing)"
    fail_on_error "$r" "Price lookup"
    printf '%s' "$r" | jq -r --arg t "$HETZNER_SERVER_TYPE" --arg l "$loc" '
      .pricing as $p
      | ([$p.server_types[] | select(.name==$t) | .prices[] | select(.location==$l) | .price_monthly.gross | tonumber][0]) as $srv
      | ([$p.primary_ips[] | select(.type=="ipv4") | .prices[] | select(.location==$l) | .price_monthly.gross | tonumber][0]) as $ip
      | "Server \($t) in \($l): \($srv) \($p.currency)/month\nIPv4 address: \($ip) \($p.currency)/month\nTotal: \(($srv + $ip) * 100 | round / 100) \($p.currency)/month (tax may be added for your country)"'
    ;;

  ssh-key)
    need ssh-keygen
    if [ ! -f "$SSH_KEY_PATH" ]; then
      mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
      ssh-keygen -t ed25519 -N "" -C "warmbly-kit" -f "$SSH_KEY_PATH" >/dev/null
      say "Made a new SSH key: $SSH_KEY_PATH"
    else
      say "Using the existing SSH key: $SSH_KEY_PATH"
    fi
    pub="$(cut -d' ' -f1,2 < "$SSH_KEY_PATH.pub")"
    r="$(api GET '/ssh_keys?per_page=50')"
    fail_on_error "$r" "SSH key list"
    id="$(printf '%s' "$r" | jq -r --arg k "$pub" '.ssh_keys[] | select((.public_key | split(" ")[0:2] | join(" ")) == $k) | .id' | head -1)"
    if [ -z "$id" ]; then
      body="$(jq -n --arg n "$HETZNER_SSH_KEY_NAME" --arg k "$(cat "$SSH_KEY_PATH.pub")" '{name:$n, public_key:$k}')"
      r="$(api POST /ssh_keys "$body")"
      fail_on_error "$r" "SSH key upload"
      id="$(printf '%s' "$r" | jq -r '.ssh_key.id // empty')"
      [ "$DRY" = 1 ] || say "Uploaded the SSH key to Hetzner."
    else
      say "Hetzner already has this SSH key."
    fi
    [ "$DRY" = 1 ] || state_set hetzner_ssh_key_id "$id"
    ;;

  firewall)
    r="$(api GET "/firewalls?name=$HETZNER_FIREWALL_NAME")"
    fail_on_error "$r" "Firewall lookup"
    id="$(printf '%s' "$r" | jq -r '.firewalls[0].id // empty')"
    if [ -z "$id" ]; then
      body="$(jq -n --arg n "$HETZNER_FIREWALL_NAME" '
        def r(p): {direction:"in", protocol:"tcp", port:p, source_ips:["0.0.0.0/0","::/0"]};
        {name:$n, labels:{app:"warmbly"},
         rules:[r("22"), r("80"), r("443"),
                {direction:"in", protocol:"icmp", source_ips:["0.0.0.0/0","::/0"]}]}')"
      r="$(api POST /firewalls "$body")"
      fail_on_error "$r" "Firewall create"
      id="$(printf '%s' "$r" | jq -r '.firewall.id // empty')"
      [ "$DRY" = 1 ] || say "Created firewall $HETZNER_FIREWALL_NAME (in: 22, 80, 443, ping)."
    else
      say "Firewall $HETZNER_FIREWALL_NAME already exists."
    fi
    [ "$DRY" = 1 ] || state_set hetzner_firewall_id "$id"
    ;;

  create-server)
    r="$(api GET "/servers?name=$HETZNER_SERVER_NAME")"
    fail_on_error "$r" "Server lookup"
    if [ "$(printf '%s' "$r" | jq '.servers | length')" != 0 ]; then
      ip="$(printf '%s' "$r" | jq -r '.servers[0].public_net.ipv4.ip')"
      [ "$DRY" = 1 ] && { say "Server $HETZNER_SERVER_NAME already exists at $ip."; exit 0; }
      state_set hetzner_server_id "$(printf '%s' "$r" | jq -r '.servers[0].id')"
      state_set server_ip "$ip"
      say "Server $HETZNER_SERVER_NAME already exists at $ip. Nothing new was bought."
      exit 0
    fi
    key_id="$(state_get hetzner_ssh_key_id)"; fw_id="$(state_get hetzner_firewall_id)"
    if [ "$DRY" = 0 ]; then
      [ -n "$key_id" ] || die "Run 'hetzner.sh ssh-key' first."
      [ -n "$fw_id" ]  || die "Run 'hetzner.sh firewall' first."
    fi
    for loc in $HETZNER_LOCATIONS; do
      body="$(jq -n --arg n "$HETZNER_SERVER_NAME" --arg t "$HETZNER_SERVER_TYPE" \
        --arg l "$loc" --arg i "$HETZNER_IMAGE" --arg k "${key_id:-0}" --arg f "${fw_id:-0}" '
        {name:$n, server_type:$t, location:$l, image:$i,
         ssh_keys:[($k|tonumber)], firewalls:[{firewall:($f|tonumber)}],
         public_net:{enable_ipv4:true, enable_ipv6:true}, labels:{app:"warmbly"}}')"
      r="$(api POST /servers "$body")"
      [ "$DRY" = 1 ] && exit 0
      code="$(printf '%s' "$r" | jq -r '.error.code // empty')"
      if [ -z "$code" ]; then
        ip="$(printf '%s' "$r" | jq -r '.server.public_net.ipv4.ip')"
        state_set hetzner_server_id "$(printf '%s' "$r" | jq -r '.server.id')"
        state_set server_ip "$ip"
        state_set server_location "$loc"
        say "Created server $HETZNER_SERVER_NAME ($HETZNER_SERVER_TYPE) in $loc at $ip."
        exit 0
      fi
      case "$code" in
        resource_unavailable|placement_error|server_type_unavailable|unavailable)
          warn "No $HETZNER_SERVER_TYPE free in $loc ($code). Trying the next location." ;;
        *)
          die "Server create failed: $(printf '%s' "$r" | jq -r '.error.code + ": " + .error.message')" ;;
      esac
    done
    die "No location in '$HETZNER_LOCATIONS' had a $HETZNER_SERVER_TYPE free. Ask the user before trying another size or place."
    ;;

  wait)
    id="$(state_get hetzner_server_id)"; [ -n "$id" ] || die "No server saved yet."
    ip="$(state_get server_ip)"
    i=0
    until [ "$(api GET "/servers/$id" | jq -r '.server.status')" = running ]; do
      i=$((i+1)); [ $i -gt 60 ] && die "The server did not reach 'running' in 5 minutes."
      sleep 5
    done
    say "Server is running. Waiting for SSH on $ip ..."
    i=0
    until nc -z -G 5 "$ip" 22 >/dev/null 2>&1; do
      i=$((i+1)); [ $i -gt 60 ] && die "SSH did not open in 5 minutes."
      sleep 5
    done
    say "SSH is open."
    ;;

  ssh-config)
    ip="$(state_get server_ip)"; [ -n "$ip" ] || die "No server IP saved yet."
    cfg="$HOME/.ssh/config"
    mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"; touch "$cfg"; chmod 600 "$cfg"
    begin="# >>> warmbly-kit (managed block)"; end="# <<< warmbly-kit"
    tmp="$(mktemp)"
    awk -v b="$begin" -v e="$end" '$0==b{skip=1} !skip{print} $0==e{skip=0}' "$cfg" > "$tmp"
    if grep -Eq "^Host[[:space:]]+$SSH_HOST_ALIAS([[:space:]]|$)" "$tmp"; then
      rm -f "$tmp"
      die "~/.ssh/config already has a 'Host $SSH_HOST_ALIAS' entry the kit did not write. Ask the user before changing it."
    fi
    {
      cat "$tmp"
      printf '\n%s\nHost %s\n  HostName %s\n  User root\n  IdentityFile %s\n  IdentitiesOnly yes\n%s\n' \
        "$begin" "$SSH_HOST_ALIAS" "$ip" "$SSH_KEY_PATH" "$end"
    } > "$cfg"
    rm -f "$tmp"
    # A rebuilt server can reuse an IP. Drop any old host key for it.
    ssh-keygen -R "$ip" -f "$HOME/.ssh/known_hosts" >/dev/null 2>&1 || true
    ssh -F "$cfg" -o StrictHostKeyChecking=accept-new -o BatchMode=yes -o ConnectTimeout=15 "$SSH_HOST_ALIAS" true
    say "Added 'Host $SSH_HOST_ALIAS' to ~/.ssh/config and connected once to record the server's key."
    ;;

  status)
    id="$(state_get hetzner_server_id)"; [ -n "$id" ] || die "No server saved yet."
    api GET "/servers/$id" | jq '{name:.server.name, status:.server.status, type:.server.server_type.name,
      location:.server.datacenter.location.name, ipv4:.server.public_net.ipv4.ip, ipv6:.server.public_net.ipv6.ip}'
    ;;

  *)
    sed -n '2,17p' "$0"; exit 1 ;;
esac
