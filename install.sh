#!/bin/sh
# ═══════════════════════════════════════════════
# FLClash for OpenWrt - Universal Installer
# Repo: https://github.com/jahid421/openwrt-flclash
# Supports: ALL OpenWrt-compatible routers
# ═══════════════════════════════════════════════

set -e

REPO="https://raw.githubusercontent.com/jahid421/openwrt-flclash/main"
V="v1.18.10"
D="/etc/mihomo"

echo "╔══════════════════════════════════════╗"
echo "║  FLClash for OpenWrt Installer       ║"
echo "║  Auto-bypass TUN Mode                ║"
echo "║  Universal (All Architectures)       ║"
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
        wget -q -O "$out" "$url" 2>/dev/null
    else
        curl -sL -o "$out" "$url" 2>/dev/null
    fi
}

echo "[✓] Download tool ready"

# ═══════════════════════════════════════════════
# Architecture detection (OpenWrt DISTRIB_ARCH priority)
# ═══════════════════════════════════════════════
UNAME_ARCH=$(uname -m)
OWRT_ARCH=$(. /etc/openwrt_release 2>/dev/null; echo "$DISTRIB_ARCH")
OWRT_TARGET=$(. /etc/openwrt_release 2>/dev/null; echo "$DISTRIB_TARGET")

echo "[*] Detecting architecture..."
echo "    uname -m: $UNAME_ARCH"
echo "    OpenWrt:  $OWRT_ARCH"
echo "    Target:   $OWRT_TARGET"

# Use OpenWrt DISTRIB_ARCH first (more reliable), fallback to uname
detect_arch() {
    local a="$1"
    case "$a" in
        # x86_64 / amd64
        x86_64*|amd64*)
            echo "amd64-compatible"
            return
            ;;
        # ARM 64-bit
        aarch64*|arm64*)
            echo "arm64"
            return
            ;;
        # ARM 32-bit v7 (Cortex-A7/A8/A9/A15/A17)
        armv7*|arm_cortex-a7*|arm_cortex-a8*|arm_cortex-a9*|arm_cortex-a15*|arm_cortex-a17*)
            echo "armv7"
            return
            ;;
        # ARM 32-bit v6
        armv6*|arm_arm1176*|arm_arm1136*)
            echo "armv6"
            return
            ;;
        # ARM 32-bit v5
        armv5*|arm_arm926*|arm_mpcore*|arm_fa526*|arm_xscale*)
            echo "armv5"
            return
            ;;
        # MIPS 64 little-endian
        mips64el*|mips64le*)
            echo "mips64le"
            return
            ;;
        # MIPS 64 big-endian
        mips64*|mips_octeonplus*)
            echo "mips64"
            return
            ;;
        # MIPS 32 little-endian (MediaTek MT7621/MT7620/MT7628, Ralink)
        mipsel*|mipsle*|mipsel_24kc*|mipsel_74kc*|mipsel_mips32*)
            echo "mipsle-softfloat"
            return
            ;;
        # MIPS 32 big-endian (Atheros AR71xx/AR9344/QCA95xx)
        mips*|mips_24kc*|mips_4kec*|mips_mips32*)
            echo "mips-softfloat"
            return
            ;;
        # RISC-V 64
        riscv64*)
            echo "riscv64"
            return
            ;;
        # i386
        i386*|i686*)
            echo "386"
            return
            ;;
        # LoongArch
        loongarch64*)
            echo "loong64"
            return
            ;;
    esac
    echo ""
}

# Try OpenWrt arch first
M=$(detect_arch "$OWRT_ARCH")

# Fallback to uname if OpenWrt arch failed
if [ -z "$M" ]; then
    M=$(detect_arch "$UNAME_ARCH")
fi

# Final fallback
if [ -z "$M" ]; then
    echo "ERROR: Cannot detect architecture!"
    echo "  uname: $UNAME_ARCH"
    echo "  owrt:  $OWRT_ARCH"
    echo ""
    echo "Please report this at: https://github.com/jahid421/openwrt-flclash/issues"
    exit 1
fi

echo "[✓] Architecture: $M"

# ═══════════════════════════════════════════════
# Space check
# ═══════════════════════════════════════════════
AVAIL=$(df / | tail -1 | awk '{print $4}')
if [ "$AVAIL" -lt 30000 ]; then
    echo ""
    echo "⚠️  WARNING: Low disk space ($((AVAIL/1024)) MB free)"
    echo "   Required: ~40 MB"
    echo "   Small routers (16MB flash) need USB extroot!"
    echo "   Examples: RB750Gr3, TP-Link Archer C7, older devices"
    echo ""
    echo "   Continue anyway? (5 sec to cancel with Ctrl+C)"
    sleep 5
fi

# ═══════════════════════════════════════════════
# Install dependencies (including luci-compat!)
# ═══════════════════════════════════════════════
echo "[*] Installing dependencies..."
opkg update >/dev/null 2>&1

# Core dependencies
for p in curl ca-bundle ca-certificates ip-full kmod-tun kmod-nft-tproxy coreutils-nohup; do
    opkg install $p >/dev/null 2>&1 || true
done

# LuCI compatibility layer (essential for menu!)
for p in luci-compat luci-lib-ipkg luci-lib-nixio; do
    opkg install $p >/dev/null 2>&1 || true
done

echo "[✓] Dependencies installed"

# ═══════════════════════════════════════════════
# Download Mihomo binary with fallback
# ═══════════════════════════════════════════════
echo "[*] Downloading Mihomo core ($M)..."
cd /tmp && rm -f mihomo.gz mihomo

download_and_verify() {
    local arch="$1"
    local url="https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$arch-$V.gz"
    echo "    Trying: $arch"
    dl "$url" mihomo.gz
    
    # Check if download succeeded
    [ -s mihomo.gz ] || return 1
    
    # Check gzip integrity
    gzip -t mihomo.gz 2>/dev/null || return 1
    
    # Extract
    gunzip -f mihomo.gz 2>/dev/null || return 1
    chmod +x mihomo
    
    # Test binary
    if ./mihomo -v >/dev/null 2>&1; then
        return 0
    else
        rm -f mihomo mihomo.gz
        return 1
    fi
}

# Try primary detected arch
if download_and_verify "$M"; then
    echo "[✓] Downloaded: $M"
else
    echo "[!] $M failed, trying alternatives..."
    
    # Smart alternatives based on architecture family
    case "$M" in
        mips-softfloat)
            ALTS="mipsle-softfloat"
            ;;
        mipsle-softfloat)
            ALTS="mips-softfloat"
            ;;
        armv7)
            ALTS="armv6 armv5"
            ;;
        armv6)
            ALTS="armv7 armv5"
            ;;
        armv5)
            ALTS="armv7"
            ;;
        arm64)
            ALTS="armv7"
            ;;
        amd64-compatible)
            ALTS="amd64 386"
            ;;
        *)
            ALTS="amd64-compatible arm64 mipsle-softfloat mips-softfloat"
            ;;
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
    
    if [ "$FOUND" = "0" ]; then
        echo "ERROR: No compatible binary found!"
        echo "Detected arch: $M"
        echo "Please report at: https://github.com/jahid421/openwrt-flclash/issues"
        echo ""
        echo "Available architectures:"
        echo "  https://github.com/MetaCubeX/mihomo/releases"
        exit 1
    fi
fi

mv mihomo /usr/bin/mihomo
echo "[✓] Mihomo installed: $(/usr/bin/mihomo -v 2>&1 | head -1)"

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
# Auto-detect LAN IP and add to config
# ═══════════════════════════════════════════════
RIP=$(uci -q get network.lan.ipaddr || echo "192.168.1.1")
LAN_NET=$(echo $RIP | awk -F. '{print $1"."$2"."$3".0/24"}')
echo "[*] Router LAN: $RIP ($LAN_NET)"

# Remove any old VM IPs and add current LAN
sed -i '/192.168.87.0\/24/d' $D/config.yaml 2>/dev/null
sed -i '/192.168.64.0\/24/d' $D/config.yaml 2>/dev/null

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
echo "║  Architecture: $M                    "
echo "║                                      ║"
echo "╚══════════════════════════════════════╝"

echo ""
pgrep -f mihomo && echo "Mihomo: RUNNING ✅" || echo "Mihomo: STOPPED ❌ (check: logread | grep mihomo)"
ip a show utun 2>/dev/null | head -3 && echo "TUN: ACTIVE ✅" || echo "TUN: Not created yet"

echo ""
echo "══════════════════════════════════════"
echo "Support: https://github.com/jahid421/openwrt-flclash"
echo "══════════════════════════════════════"
