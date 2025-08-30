#!/usr/bin/env bash
# Ubuntu 22.x: Block ICMP timestamp request (13) IN and timestamp reply (14) OUT
# Safe to run multiple times. Requires root.

set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run as root (sudo $0)"; exit 1; }

# If an earlier nft-only table exists, remove it (harmless if not present)
if command -v nft >/dev/null 2>&1; then
  nft list table inet icmp_filter >/dev/null 2>&1 && nft delete table inet icmp_filter || true
fi

# Ensure iptables is present (nft backend is fine)
command -v iptables >/dev/null 2>&1 || { apt-get update -y && apt-get install -y iptables; }

ipt() { iptables -w 5 "$@"; }  # wait for xtables lock

ensure_rule() {
  local chain="$1"; shift
  if ! ipt -C "$chain" "$@" 2>/dev/null; then
    ipt -I "$chain" "$@"
    echo "Inserted: iptables -I $chain $*"
  else
    echo "Exists:   iptables -C $chain $*"
  fi
}

# 1) Drop inbound ICMP timestamp requests (type 13)
ensure_rule INPUT  -p icmp --icmp-type timestamp-request -j DROP

# 2) Drop outbound ICMP timestamp replies (type 14)
ensure_rule OUTPUT -p icmp --icmp-type timestamp-reply  -j DROP

echo
echo "Active matching rules:"
ipt -L INPUT  -n --line-numbers | awk '/icmp/ && /(timestamp|13)/'
ipt -L OUTPUT -n --line-numbers | awk '/icmp/ && /(timestamp|14)/'

cat <<'EONOTE'

Note: These rules last until reboot. To persist across reboots:

  sudo apt-get update
  sudo apt-get install -y iptables-persistent -o Dpkg::Options::=--force-confnew
  sudo sh -c 'iptables-save > /etc/iptables/rules.v4'

To remove these rules later:

  sudo iptables -D INPUT  -p icmp --icmp-type timestamp-request -j DROP
  sudo iptables -D OUTPUT -p icmp --icmp-type timestamp-reply  -j DROP

Quick test (from another host):

  hping3 --icmp --icmptype 13 <SERVER_IP>
  # Expect: no reply

On the server, watch counters:

  sudo iptables -vL | grep -E 'icmp|timestamp'

EONOTE
