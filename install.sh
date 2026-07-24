#!/bin/sh
# ═══════════════════════════════════════════════
# FLClash for OpenWrt - Lightweight Installer
# Repo: https://github.com/jahid421/openwrt-flclash
# Features: TUN mode auto-bypass, LuCI panel, YAML upload
# ═══════════════════════════════════════════════

set -e

REPO="https://raw.githubusercontent.com/jahid421/openwrt-flclash/main"
V="v1.18.10"
D="/etc/mihomo"

echo "╔══════════════════════════════════════╗"
echo "║  FLClash for OpenWrt Installer       ║"
echo "║  Auto-bypass TUN Mode                ║"
echo "╚══════════════════════════════════════╝"
echo ""

[ -f /etc/openwrt_release ] || { echo "ERROR: OpenWrt only!"; exit 1; }
echo "[✓] OpenWrt detected"

A=$(uname -m)
case "$A" in
  x86_64) M="amd64-compatible" ;;
  aarch64) M="arm64" ;;
  armv7l) M="armv7" ;;
  mips) M="mips-softfloat" ;;
  mipsel) M="mipsle-softfloat" ;;
  *) echo "ERROR: Unsupported arch: $A"; exit 1 ;;
esac
echo "[✓] Architecture: $M"

echo "[*] Installing dependencies..."
opkg update >/dev/null 2>&1
for p in curl ca-bundle ca-certificates ip-full kmod-tun kmod-nft-tproxy coreutils-nohup luci-compat luci-lib-ipkg; do
  opkg install $p >/dev/null 2>&1 || true
done
echo "[✓] Dependencies installed"

echo "[*] Downloading Mihomo core..."
cd /tmp && rm -f mihomo.gz
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
gunzip -f mihomo.gz
chmod +x mihomo
mv mihomo /usr/bin/mihomo
echo "[✓] Mihomo installed"

mkdir -p $D/profiles $D/providers $D/ruleset $D/ui $D/scripts

# Transparent proxy ON by default (FLClash-like behavior)
echo "1" > $D/transparent

echo "[*] Downloading GeoIP databases..."
cd $D
curl -sL -o geoip.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat" 2>/dev/null || true
curl -sL -o geosite.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat" 2>/dev/null || true
curl -sL -o Country.mmdb "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb" 2>/dev/null || true
echo "[✓] GeoIP ready"

echo "[*] Downloading MetaCubeXD dashboard..."
cd /tmp && rm -f ui.tgz
curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
rm -rf $D/ui/*
tar -xzf ui.tgz -C $D/ui/ 2>/dev/null
rm -f ui.tgz
echo "[✓] Dashboard installed"

echo "[*] Downloading FLClash panel from repo..."
curl -sL -o /etc/init.d/mihomo "$REPO/files/mihomo.init"
chmod +x /etc/init.d/mihomo

curl -sL -o $D/config.yaml "$REPO/files/config.default.yaml"
curl -sL -o $D/nft.conf "$REPO/files/nft.conf" 2>/dev/null || true

mkdir -p /www/cgi-bin
curl -sL -o /www/cgi-bin/mihomo-api "$REPO/files/mihomo-api"
curl -sL -o /www/cgi-bin/mihomo-cfg "$REPO/files/mihomo-cfg"
curl -sL -o /www/cgi-bin/mihomo-sub "$REPO/files/mihomo-sub"
chmod +x /www/cgi-bin/mihomo-*

mkdir -p /usr/lib/lua/luci/controller
curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "$REPO/files/mihomo.lua"

mkdir -p /usr/lib/lua/luci/view/mihomo
curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "$REPO/files/main.htm"

echo "[✓] Panel installed"

# Firewall rule for LAN access to proxy ports
uci -q delete firewall.mihomo_proxy 2>/dev/null
uci set firewall.mihomo_proxy=rule
uci set firewall.mihomo_proxy.name='Allow-Mihomo-Proxy'
uci set firewall.mihomo_proxy.src='lan'
uci set firewall.mihomo_proxy.proto='tcp udp'
uci set firewall.mihomo_proxy.dest_port='7890 9595 1053'
uci set firewall.mihomo_proxy.target='ACCEPT'
uci commit firewall
/etc/init.d/firewall restart 2>/dev/null || true

/etc/init.d/mihomo enable

rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

/etc/init.d/mihomo start
sleep 8

RIP=$(uci -q get network.lan.ipaddr || echo "192.168.1.1")

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       ✅ INSTALL COMPLETE!           ║"
echo "╠══════════════════════════════════════╣"
echo "║                                      ║"
echo "║  🎯 Auto-Bypass: ENABLED (TUN mode)  ║"
echo "║  All devices auto-use proxy!         ║"
echo "║                                      ║"
echo "║  LuCI:      http://$RIP        ║"
echo "║  → Services → Mihomo                 ║"
echo "║                                      ║"
echo "║  Dashboard: http://$RIP:9595/ui  ║"
echo "║  Secret:    flclash123               ║"
echo "║                                      ║"
echo "║  📄 Upload YAML from LuCI panel     ║"
echo "║                                      ║"
echo "╚══════════════════════════════════════╝"

pgrep -f mihomo && echo "Mihomo: RUNNING ✅" || echo "Mihomo: STOPPED ❌"
ip a show utun 2>/dev/null | head -3 && echo "TUN: ACTIVE ✅" || echo "TUN: Not created yet"
