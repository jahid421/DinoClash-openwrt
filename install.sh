#!/bin/sh
# ═══════════════════════════════════════════════
# FLClash for OpenWrt - Lightweight Installer
# Repo: https://github.com/jahid421/openwrt-flclash
# ═══════════════════════════════════════════════

set -e

REPO="https://raw.githubusercontent.com/jahid421/openwrt-flclash/main"
V="v1.18.10"
D="/etc/mihomo"
PORT="9595"
SECRET="flclash123"

echo "╔══════════════════════════════════════╗"
echo "║  FLClash for OpenWrt Installer       ║"
echo "║  Lightweight Mihomo + Custom UI      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Check OpenWrt
[ -f /etc/openwrt_release ] || { echo "ERROR: OpenWrt only!"; exit 1; }
echo "[✓] OpenWrt detected"

# Detect architecture
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

# Install dependencies
echo "[*] Installing dependencies..."
opkg update >/dev/null 2>&1
for p in curl ca-bundle ca-certificates ip-full kmod-tun kmod-nft-tproxy coreutils-nohup; do
  opkg install $p >/dev/null 2>&1 || true
done
echo "[✓] Dependencies installed"

# Download Mihomo binary
echo "[*] Downloading Mihomo core..."
cd /tmp && rm -f mihomo.gz
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
gunzip -f mihomo.gz
chmod +x mihomo
mv mihomo /usr/bin/mihomo
echo "[✓] Mihomo installed"

# Create directories
mkdir -p $D/profiles $D/providers $D/ruleset $D/ui $D/scripts

# Download GeoIP databases
echo "[*] Downloading GeoIP databases..."
cd $D
curl -sL -o geoip.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat" 2>/dev/null || true
curl -sL -o geosite.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat" 2>/dev/null || true
curl -sL -o Country.mmdb "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb" 2>/dev/null || true
echo "[✓] GeoIP ready"

# Download MetaCubeXD dashboard
echo "[*] Downloading dashboard..."
cd /tmp && rm -f ui.tgz
curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
rm -rf $D/ui/*
tar -xzf ui.tgz -C $D/ui/ 2>/dev/null
rm -f ui.tgz
echo "[✓] Dashboard installed"

# Download files from GitHub repo
echo "[*] Downloading FLClash panel from repo..."
curl -sL -o /etc/init.d/mihomo "$REPO/files/mihomo.init"
chmod +x /etc/init.d/mihomo

curl -sL -o $D/config.yaml "$REPO/files/config.yaml"
curl -sL -o $D/nft.conf "$REPO/files/nft.conf"

# CGI backend
mkdir -p /www/cgi-bin
curl -sL -o /www/cgi-bin/mihomo-api "$REPO/files/mihomo-api"
curl -sL -o /www/cgi-bin/mihomo-cfg "$REPO/files/mihomo-cfg"
curl -sL -o /www/cgi-bin/mihomo-sub "$REPO/files/mihomo-sub"
chmod +x /www/cgi-bin/mihomo-*

# LuCI controller
mkdir -p /usr/lib/lua/luci/controller
curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "$REPO/files/mihomo.lua"

# LuCI view (main HTML page)
mkdir -p /usr/lib/lua/luci/view/mihomo
curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "$REPO/files/main.htm"

echo "[✓] Panel installed"

# Enable service
/etc/init.d/mihomo enable

# Cache clear
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

# Start
/etc/init.d/mihomo start
sleep 3

RIP=$(uci -q get network.lan.ipaddr || echo "192.168.1.1")

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       ✅ INSTALL COMPLETE!           ║"
echo "╠══════════════════════════════════════╣"
echo "║                                      ║"
echo "║  LuCI:      http://$RIP        ║"
echo "║  → Services → Mihomo                 ║"
echo "║                                      ║"
echo "║  Dashboard: http://$RIP:9595/ui  ║"
echo "║  Secret:    flclash123               ║"
echo "║                                      ║"
echo "╚══════════════════════════════════════╝"

pgrep -f mihomo && echo "Mihomo: RUNNING ✅" || echo "Mihomo: STOPPED ❌"
