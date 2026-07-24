#!/bin/sh
# ═══════════════════════════════════════════════
# FLClash for OpenWrt - Lightweight Installer
# Repo: https://github.com/jahid421/openwrt-flclash
# Supports: x86_64, arm64, armv7, mips, mipsel
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

# Check OpenWrt
[ -f /etc/openwrt_release ] || { echo "ERROR: OpenWrt only!"; exit 1; }
echo "[✓] OpenWrt detected"

# ═══════════════════════════════════════════════
# Auto-install curl if missing
# ═══════════════════════════════════════════════
if ! command -v curl >/dev/null 2>&1; then
    echo "[*] curl not found, installing..."
    opkg update >/dev/null 2>&1
    opkg install curl ca-bundle ca-certificates >/dev/null 2>&1 || {
        if command -v wget >/dev/null 2>&1; then
            echo "[!] curl install failed, will use wget"
            USE_WGET=1
        else
            echo "ERROR: Neither curl nor wget available!"
            echo "Please install manually: opkg install curl"
            exit 1
        fi
    }
fi

# Download function (curl or wget)
dl() {
    local url="$1"
    local out="$2"
    if [ "$USE_WGET" = "1" ]; then
        wget -q -O "$out" "$url"
    else
        curl -sL -o "$out" "$url"
    fi
}

echo "[✓] Download tool ready"

# ═══════════════════════════════════════════════
# Architecture detection (improved)
# ═══════════════════════════════════════════════
A=$(uname -m)
OWRT_ARCH=$(. /etc/openwrt_release 2>/dev/null; echo "$DISTRIB_ARCH")

echo "[*] Detecting architecture..."
echo "    uname -m: $A"
echo "    OpenWrt:  $OWRT_ARCH"

case "$A" in
  x86_64|amd64)
    M="amd64-compatible"
    ;;
  aarch64|arm64)
    M="arm64"
    ;;
  armv7l|armv7)
    M="armv7"
    ;;
  armv6l|armv6)
    M="armv7"
    ;;
  armv5*)
    M="armv5"
    ;;
  mips)
    # Big-endian mips (MediaTek MT7621 = RB750Gr3, Xiaomi 4A, etc)
    M="mips-softfloat"
    ;;
  mipsel|mipsle)
    # Little-endian mips
    M="mipsle-softfloat"
    ;;
  mips64)
    M="mips64"
    ;;
  mips64el|mips64le)
    M="mips64le"
    ;;
  *)
    # Fallback: check OpenWrt arch
    case "$OWRT_ARCH" in
      *mipsel*|*mipsle*) M="mipsle-softfloat" ;;
      *mips64el*|*mips64le*) M="mips64le" ;;
      *mips64*) M="mips64" ;;
      *mips*) M="mips-softfloat" ;;
      *aarch64*|*arm64*) M="arm64" ;;
      *arm_cortex-a15*|*armv7*) M="armv7" ;;
      *arm*) M="armv7" ;;
      *x86_64*|*amd64*) M="amd64-compatible" ;;
      *) echo "ERROR: Unsupported arch: $A ($OWRT_ARCH)"; exit 1 ;;
    esac
    ;;
esac
echo "[✓] Architecture: $M"

# ═══════════════════════════════════════════════
# Space check
# ═══════════════════════════════════════════════
AVAIL=$(df / | tail -1 | awk '{print $4}')
if [ "$AVAIL" -lt 30000 ]; then
    echo ""
    echo "⚠️  WARNING: Low disk space ($((AVAIL/1024)) MB free)"
    echo "   Required: ~40 MB"
    echo "   Consider USB extroot for small routers (RB750Gr3 with 16MB flash)"
    echo ""
    echo "   Continue anyway? (5 sec to cancel with Ctrl+C)"
    sleep 5
fi

# ═══════════════════════════════════════════════
# Install dependencies (including luci-compat!)
# ═══════════════════════════════════════════════
echo "[*] Installing dependencies..."
opkg update >/dev/null 2>&1
for p in curl ca-bundle ca-certificates ip-full kmod-tun kmod-nft-tproxy coreutils-nohup luci-compat luci-lib-ipkg; do
  opkg install $p >/dev/null 2>&1 || true
done
echo "[✓] Dependencies installed"

# ═══════════════════════════════════════════════
# Download Mihomo binary
# ═══════════════════════════════════════════════
echo "[*] Downloading Mihomo core ($M)..."
cd /tmp && rm -f mihomo.gz mihomo

URL="https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
echo "    URL: $URL"

dl "$URL" mihomo.gz

# Verify download
if [ ! -s mihomo.gz ]; then
    echo "ERROR: Download failed!"
    exit 1
fi

# Test gzip integrity
if ! gzip -t mihomo.gz 2>/dev/null; then
    echo "ERROR: Downloaded file is not a valid gzip!"
    echo "This might be wrong architecture. Trying alternatives..."
    
    # Try alternatives
    for ALT in "$M" "amd64-compatible" "mips-softfloat" "mipsle-softfloat"; do
        echo "Trying: $ALT"
        rm -f mihomo.gz
        dl "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$ALT-$V.gz" mihomo.gz
        if [ -s mihomo.gz ] && gzip -t mihomo.gz 2>/dev/null; then
            echo "[✓] Alternative works: $ALT"
            M="$ALT"
            break
        fi
    done
fi

gunzip -f mihomo.gz
chmod +x mihomo
mv mihomo /usr/bin/mihomo

# Verify binary works
if ! /usr/bin/mihomo -v >/dev/null 2>&1; then
    echo "ERROR: Binary doesn't run on this system!"
    echo "Wrong architecture. Detected: $M"
    echo "Check https://github.com/MetaCubeX/mihomo/releases for correct arch"
    exit 1
fi

echo "[✓] Mihomo installed and verified"

# ═══════════════════════════════════════════════
# Setup directories
# ═══════════════════════════════════════════════
mkdir -p $D/profiles $D/providers $D/ruleset $D/ui $D/scripts

# Enable transparent proxy by default (FLClash-like)
echo "1" > $D/transparent

# ═══════════════════════════════════════════════
# Download GeoIP databases
# ═══════════════════════════════════════════════
echo "[*] Downloading GeoIP databases..."
cd $D
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat" geoip.dat 2>/dev/null || true
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat" geosite.dat 2>/dev/null || true
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb" Country.mmdb 2>/dev/null || true
echo "[✓] GeoIP ready"

# ═══════════════════════════════════════════════
# Download MetaCubeXD dashboard
# ═══════════════════════════════════════════════
echo "[*] Downloading dashboard..."
cd /tmp && rm -f ui.tgz
dl "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz" ui.tgz 2>/dev/null || true
rm -rf $D/ui/*
tar -xzf ui.tgz -C $D/ui/ 2>/dev/null || true
rm -f ui.tgz
echo "[✓] Dashboard installed"

# ═══════════════════════════════════════════════
# Download panel files from GitHub
# ═══════════════════════════════════════════════
echo "[*] Downloading FLClash panel from repo..."
dl "$REPO/files/mihomo.init" /etc/init.d/mihomo
chmod +x /etc/init.d/mihomo

dl "$REPO/files/config.default.yaml" $D/config.yaml
dl "$REPO/files/nft.conf" $D/nft.conf 2>/dev/null || true

# CGI backend
mkdir -p /www/cgi-bin
dl "$REPO/files/mihomo-api" /www/cgi-bin/mihomo-api
dl "$REPO/files/mihomo-cfg" /www/cgi-bin/mihomo-cfg
dl "$REPO/files/mihomo-sub" /www/cgi-bin/mihomo-sub
chmod +x /www/cgi-bin/mihomo-*

# LuCI controller
mkdir -p /usr/lib/lua/luci/controller
dl "$REPO/files/mihomo.lua" /usr/lib/lua/luci/controller/mihomo.lua

# LuCI view
mkdir -p /usr/lib/lua/luci/view/mihomo
dl "$REPO/files/main.htm" /usr/lib/lua/luci/view/mihomo/main.htm

echo "[✓] Panel installed"

# ═══════════════════════════════════════════════
# Firewall rule for LAN access
# ═══════════════════════════════════════════════
uci -q delete firewall.mihomo_proxy 2>/dev/null
uci set firewall.mihomo_proxy=rule
uci set firewall.mihomo_proxy.name='Allow-Mihomo-Proxy'
uci set firewall.mihomo_proxy.src='lan'
uci set firewall.mihomo_proxy.proto='tcp udp'
uci set firewall.mihomo_proxy.dest_port='7890 9595 1053'
uci set firewall.mihomo_proxy.target='ACCEPT'
uci commit firewall
/etc/init.d/firewall restart 2>/dev/null || true

# ═══════════════════════════════════════════════
# Auto-fix LAN IP in config
# ═══════════════════════════════════════════════
RIP=$(uci -q get network.lan.ipaddr || echo "192.168.1.1")
LAN_NET=$(echo $RIP | awk -F. '{print $1"."$2"."$3".0/24"}')
echo "[*] Router LAN: $RIP ($LAN_NET)"

# Add LAN network to config if not present
if ! grep -q "$LAN_NET,DIRECT" $D/config.yaml; then
    sed -i "/^rules:/a\\
  - 'IP-CIDR,$LAN_NET,DIRECT,no-resolve'" $D/config.yaml
fi

# ═══════════════════════════════════════════════
# Enable & Start
# ═══════════════════════════════════════════════
/etc/init.d/mihomo enable

# Cache clear
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

# Start
/etc/init.d/mihomo start
sleep 8

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       ✅ INSTALL COMPLETE!           ║"
echo "╠══════════════════════════════════════╣"
echo "║                                      ║"
echo "║  🎯 Auto-Bypass: ENABLED (TUN mode)  ║"
echo "║  All devices auto-use proxy!         ║"
echo "║                                      ║"
echo "║  LuCI:      http://$RIP        "
echo "║  → Services → Mihomo                 ║"
echo "║                                      ║"
echo "║  Dashboard: http://$RIP:9595/ui"
echo "║  Secret:    flclash123               ║"
echo "║                                      ║"
echo "║  📄 Upload YAML from LuCI panel      ║"
echo "║                                      ║"
echo "╚══════════════════════════════════════╝"

echo ""
pgrep -f mihomo && echo "Mihomo: RUNNING ✅" || echo "Mihomo: STOPPED ❌ (check: logread | grep mihomo)"
ip a show utun 2>/dev/null | head -3 && echo "TUN: ACTIVE ✅" || echo "TUN: Not created yet"
