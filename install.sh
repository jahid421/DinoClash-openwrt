#!/bin/sh
# ═══════════════════════════════════════════════
# 🦕 DinoClash for OpenWrt - Universal Installer
# Repo: https://github.com/jahid421/openwrt-flclash
# Developer: Jahid Hasan Shuvo
# ═══════════════════════════════════════════════

set -e

REPO="https://raw.githubusercontent.com/jahid421/openwrt-flclash/main"
V="v1.18.10"
D="/etc/mihomo"

echo "╔══════════════════════════════════════╗"
echo "║  🦕 DinoClash for OpenWrt            ║"
echo "║  Auto-bypass (Redirect Mode)         ║"
echo "║  Universal - All Architectures       ║"
echo "║  Developer: Jahid Hasan Shuvo        ║"
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
            USE_WGET=1
        else
            echo "ERROR: Neither curl nor wget available!"
            exit 1
        fi
    }
fi

dl() {
    if [ "$USE_WGET" = "1" ]; then
        wget -q -O "$2" "$1" 2>/dev/null
    else
        curl -sL -o "$2" "$1" 2>/dev/null
    fi
}

echo "[✓] Download tool ready"

# ═══════════════════════════════════════════════
# Architecture detection
# ═══════════════════════════════════════════════
OWRT_ARCH=$(. /etc/openwrt_release 2>/dev/null; echo "$DISTRIB_ARCH")
UNAME_ARCH=$(uname -m)

echo "[*] Detecting architecture..."
echo "    OpenWrt:  $OWRT_ARCH"
echo "    uname -m: $UNAME_ARCH"

A="${OWRT_ARCH:-$UNAME_ARCH}"

detect_arch() {
    case "$1" in
        x86_64*|amd64*) echo "amd64-compatible" ;;
        aarch64*|arm64*) echo "arm64" ;;
        armv7*|arm_cortex-a7*|arm_cortex-a8*|arm_cortex-a9*|arm_cortex-a15*|arm_cortex-a17*) echo "armv7" ;;
        armv6*|arm_arm1176*|arm_arm1136*) echo "armv6" ;;
        armv5*|arm_arm926*|arm_mpcore*|arm_fa526*|arm_xscale*) echo "armv5" ;;
        mips64el*|mips64le*) echo "mips64le" ;;
        mips64*|mips_octeonplus*) echo "mips64" ;;
        mipsel*|mipsle*|mipsel_24kc*|mipsel_74kc*|mipsel_mips32*) echo "mipsle-softfloat" ;;
        mips*|mips_24kc*|mips_4kec*|mips_mips32*) echo "mips-softfloat" ;;
        riscv64*) echo "riscv64" ;;
        i386*|i686*) echo "386" ;;
        loongarch64*) echo "loong64" ;;
        *) echo "" ;;
    esac
}

M=$(detect_arch "$A")
[ -z "$M" ] && M=$(detect_arch "$UNAME_ARCH")
[ -z "$M" ] && { echo "ERROR: Cannot detect architecture!"; exit 1; }

echo "[✓] Architecture: $M"

# ═══════════════════════════════════════════════
# Space check
# ═══════════════════════════════════════════════
AVAIL=$(df / | tail -1 | awk '{print $4}')
if [ "$AVAIL" -lt 30000 ]; then
    echo ""
    echo "⚠️  WARNING: Low disk space ($((AVAIL/1024)) MB free)"
    echo "   Required: ~40 MB"
    echo "   Small routers need USB extroot!"
    echo "   Continue anyway? (5 sec to cancel)"
    sleep 5
fi

# ═══════════════════════════════════════════════
# Install dependencies
# ═══════════════════════════════════════════════
echo "[*] Installing dependencies..."
opkg update >/dev/null 2>&1
for p in curl ca-bundle ca-certificates ip-full kmod-tun kmod-nft-tproxy coreutils-nohup luci-compat luci-lib-ipkg luci-lib-nixio; do
    opkg install $p >/dev/null 2>&1 || true
done
echo "[✓] Dependencies installed"

# ═══════════════════════════════════════════════
# Download Mihomo with fallback
# ═══════════════════════════════════════════════
echo "[*] Downloading DinoClash core ($M)..."
cd /tmp && rm -f mihomo.gz mihomo

download_and_verify() {
    local arch="$1"
    local url="https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$arch-$V.gz"
    echo "    Trying: $arch"
    dl "$url" mihomo.gz
    [ -s mihomo.gz ] || return 1
    gzip -t mihomo.gz 2>/dev/null || return 1
    gunzip -f mihomo.gz 2>/dev/null || return 1
    chmod +x mihomo
    if ./mihomo -v >/dev/null 2>&1; then
        return 0
    else
        rm -f mihomo mihomo.gz
        return 1
    fi
}

if download_and_verify "$M"; then
    echo "[✓] Downloaded: $M"
else
    echo "[!] $M failed, trying alternatives..."
    case "$M" in
        mips-softfloat) ALTS="mipsle-softfloat" ;;
        mipsle-softfloat) ALTS="mips-softfloat" ;;
        armv7) ALTS="armv6 armv5" ;;
        armv6) ALTS="armv7 armv5" ;;
        armv5) ALTS="armv7" ;;
        arm64) ALTS="armv7" ;;
        amd64-compatible) ALTS="amd64 386" ;;
        *) ALTS="amd64-compatible arm64 mipsle-softfloat mips-softfloat" ;;
    esac
    
    FOUND=0
    for ALT in $ALTS; do
        if download_and_verify "$ALT"; then
            echo "[✓] Alternative worked: $ALT"
            M="$ALT"
            FOUND=1
            break
        fi
    done
    
    [ "$FOUND" = "0" ] && { echo "ERROR: No compatible binary!"; exit 1; }
fi

mv mihomo /usr/bin/mihomo
echo "[✓] DinoClash core installed"

# ═══════════════════════════════════════════════
# Setup directories & state
# ═══════════════════════════════════════════════
mkdir -p $D/profiles $D/providers $D/ruleset $D/ui $D/scripts

echo "1" > $D/transparent
echo "1" > $D/enabled

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
# Download dashboard
# ═══════════════════════════════════════════════
echo "[*] Downloading dashboard..."
cd /tmp && rm -f ui.tgz
dl "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz" ui.tgz 2>/dev/null || true
rm -rf $D/ui/*
tar -xzf ui.tgz -C $D/ui/ 2>/dev/null || true
rm -f ui.tgz
echo "[✓] Dashboard installed"

# ═══════════════════════════════════════════════
# Download DinoClash panel files
# ═══════════════════════════════════════════════
echo "[*] Downloading DinoClash panel..."
dl "$REPO/files/mihomo.init" /etc/init.d/mihomo
chmod +x /etc/init.d/mihomo

dl "$REPO/files/config.default.yaml" $D/config.yaml
dl "$REPO/files/nft.conf" $D/nft.conf

mkdir -p /www/cgi-bin
dl "$REPO/files/mihomo-api" /www/cgi-bin/mihomo-api
dl "$REPO/files/mihomo-cfg" /www/cgi-bin/mihomo-cfg
dl "$REPO/files/mihomo-sub" /www/cgi-bin/mihomo-sub
chmod +x /www/cgi-bin/mihomo-*

mkdir -p /usr/lib/lua/luci/controller
dl "$REPO/files/mihomo.lua" /usr/lib/lua/luci/controller/mihomo.lua

mkdir -p /usr/lib/lua/luci/view/mihomo
dl "$REPO/files/main.htm" /usr/lib/lua/luci/view/mihomo/main.htm

echo "[✓] DinoClash panel installed"

# ═══════════════════════════════════════════════
# Auto-detect LAN interface
# ═══════════════════════════════════════════════
LAN_IF=$(uci get network.lan.device 2>/dev/null || echo "br-lan")
LAN_IP=$(uci -q get network.lan.ipaddr || echo "192.168.1.1")
sed -i "s/iifname != \"br-lan\"/iifname != \"$LAN_IF\"/g" $D/nft.conf 2>/dev/null
echo "[✓] LAN: $LAN_IP on $LAN_IF"

# ═══════════════════════════════════════════════
# Firewall rule
# ═══════════════════════════════════════════════
uci -q delete firewall.mihomo_proxy 2>/dev/null
uci set firewall.mihomo_proxy=rule
uci set firewall.mihomo_proxy.name='Allow-DinoClash'
uci set firewall.mihomo_proxy.src='lan'
uci set firewall.mihomo_proxy.proto='tcp udp'
uci set firewall.mihomo_proxy.dest_port='7890 7892 9595 1053'
uci set firewall.mihomo_proxy.target='ACCEPT'
uci commit firewall
/etc/init.d/firewall restart 2>/dev/null || true

# ═══════════════════════════════════════════════
# Enable & Start
# ═══════════════════════════════════════════════
/etc/init.d/mihomo enable

rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

/etc/init.d/mihomo start
sleep 5

echo ""
echo "╔══════════════════════════════════════╗"
echo "║    🦕 DinoClash INSTALLED! ✅        ║"
echo "╠══════════════════════════════════════╣"
echo "║                                      ║"
echo "║  🎯 Auto-Bypass: ENABLED             ║"
echo "║  All devices auto-use proxy!         ║"
echo "║                                      ║"
echo "║  LuCI:      http://$LAN_IP        "
echo "║  → Services → DinoClash              ║"
echo "║                                      ║"
echo "║  Dashboard: http://$LAN_IP:9595/ui"
echo "║  Secret:    flclash123               ║"
echo "║                                      ║"
echo "║  📄 Upload YAML from LuCI panel      ║"
echo "║                                      ║"
echo "║  Developer: Jahid Hasan Shuvo        ║"
echo "║  Architecture: $M                    "
echo "║                                      ║"
echo "╚══════════════════════════════════════╝"

echo ""
pgrep -f mihomo && echo "DinoClash: RUNNING ✅" || echo "DinoClash: STOPPED ❌"

echo ""
echo "🦕 https://github.com/jahid421/openwrt-flclash"
