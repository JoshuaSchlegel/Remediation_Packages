#!/usr/bin/env bash
# Block ICMP timestamp requests (13) inbound and timestamp replies (14) outbound on Ubuntu 22.04+
# Requires root.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo $0)"; exit 1
fi

# Ensure nftables is available
if ! command -v nft >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y nftables
fi

# Enable nftables service so rules can persist
systemctl enable --now nftables

TABLE="icmp_filter"

# Create/replace a dedicated table with input/output chains and the drop rules
nft -f - <<'EOF'
flush table inet icmp_filter 2>/dev/null
table inet icmp_filter {
  chain input {
    type filter hook input priority 0; policy accept;
    ip protocol icmp icmp type timestamp-request drop
  }
  chain output {
    type filter hook output priority 0; policy accept;
    ip protocol icmp icmp type timestamp-reply drop
  }
}
EOF

# Persist rules across reboots by saving the full ruleset
# (back up existing config first, then write current ruleset)
if [[ -f /etc/nftables.conf ]]; then
  cp -a /etc/nftables.conf /etc/nftables.conf.bak.$(date +%Y%m%d%H%M%S)
fi
nft list ruleset > /etc/nftables.conf

echo "ICMP timestamp filtering installed:"
echo " - Inbound: drop icmp type 13 (timestamp-request)"
echo " - Outbound: drop icmp type 14 (timestamp-reply)"
echo "Rules saved to /etc/nftables.conf and will persist on reboot."
