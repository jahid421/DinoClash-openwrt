#!/bin/sh
# ═══════════════════════════════════════════════
# 🦕 DinoClash for OpenWrt - Universal Installer
# With Built-in Speed Boost
# Repo: https://github.com/jahid421/DinoClash-openwrt
# Developer: Jahid Hasan Shuvo
# ═══════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main"
V="v1.18.10"
D="/etc/mihomo"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  🦕 DinoClash for OpenWrt            ║"
echo "║  Auto-bypass + Speed Boost           ║"
echo "║  Developer: Jahid Hasan Shuvo        ║"
echo "╚══════════════════════════════════════╝"
echo ""

if [ ! -f /etc/openwrt_release ]; then
    echo "❌ ERROR: This script only works on OpenWrt!"
    exit 1
fi
echo "[✓] OpenWrt detected"

OWRT_VER=$(. /etc/openwrt_release 2>/dev/null; echo "$DISTRIB_RELEASE")
echo "    Version: $OWRT_VER"

if command -v apk >/dev/null 2>&1; then
    PKG="apk"
    PKG_UPDATE="apk update"
    PKG_INSTALL="apk add"
elif command -v opkg >/dev/null 2>&1; then
    PKG="opkg"
    PKG_UPDATE="opkg update"
    PKG_INSTALL="opkg install"
else
    echo "❌ No package manager found!"
    exit 1
fi
echo "[✓] Package manager: $PKG"

USE_WGET=0
if ! command -v curl >/dev/null 2>&1; then
    $PKG_UPDATE >/dev/null 2>&1 || true
    $PKG_INSTALL curl ca-bundle ca-certificates >/dev/null 2>&1 || true
fi

if command -v curl >/dev/null 2>&1; then
    USE_WGET=0
elif command -v wget >/dev/null 2>&1; then
    USE_WGET=1
else
    echo "❌ Need curl or wget!"
    exit 1
fi

dl() {
    if [ "$USE_WGET" = "1" ]; then
        wget -q -O "$2" "$1" 2>/dev/null
    else
        curl -sL -o "$2" "$1" 2>/dev/null
    fi
}

echo "[✓] Download tool ready"

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

if [ -z "$M" ]; then
    echo "❌ Cannot detect architecture!"
    exit 1
fi
echo "[✓] Architecture: $M"

echo "[*] Installing dependencies..."
$PKG_UPDATE >/dev/null 2>&1 || true
for p in curl ca-bundle ca-certificates ip-full kmod-tun kmod-nft-tproxy coreutils-nohup; do
    $PKG_INSTALL $p >/dev/null 2>&1 || true
done
if [ "$PKG" = "opkg" ]; then
    for p in luci-compat luci-lib-ipkg luci-lib-nixio; do
        $PKG_INSTALL $p >/dev/null 2>&1 || true
    done
fi
echo "[✓] Dependencies installed"

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
    ./mihomo -v >/dev/null 2>&1 || return 1
    return 0
}

if download_and_verify "$M"; then
    echo "[✓] Downloaded: $M"
else
    echo "❌ Download failed"
    exit 1
fi

mv mihomo /usr/bin/mihomo
echo "[✓] DinoClash core installed"

mkdir -p $D/profiles $D/providers $D/ruleset $D/ui $D/scripts

# Service disabled by default (safe mode)
echo "0" > $D/transparent
echo "0" > $D/enabled

echo "[*] Downloading GeoIP..."
cd $D
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat" geoip.dat 2>/dev/null || true
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat" geosite.dat 2>/dev/null || true
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb" Country.mmdb 2>/dev/null || true
echo "[✓] GeoIP ready"

echo "[*] Downloading dashboard..."
cd /tmp && rm -f ui.tgz
dl "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz" ui.tgz 2>/dev/null || true
if [ -f /tmp/ui.tgz ] && [ -s /tmp/ui.tgz ]; then
    rm -rf $D/ui/*
    tar -xzf ui.tgz -C $D/ui/ 2>/dev/null || true
    if [ -d "$D/ui/dist" ]; then
        mv $D/ui/dist/* $D/ui/ 2>/dev/null || true
        rm -rf $D/ui/dist
    fi
    rm -f ui.tgz
    echo "[✓] Dashboard installed"
fi

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

if [ -d /usr/share/luci/menu.d ]; then
    cat > /usr/share/luci/menu.d/luci-app-dinoclash.json << 'JSONEOF'
{
    "admin/services/mihomo": {
        "title": "DinoClash \ud83e\udd95",
        "order": 60,
        "action": {
            "type": "template",
            "path": "mihomo/main"
        }
    }
}
JSONEOF
fi
echo "[✓] DinoClash panel installed"

LAN_IF=$(uci get network.lan.device 2>/dev/null || echo "br-lan")
LAN_IP=$(uci -q get network.lan.ipaddr || echo "192.168.1.1")
sed -i "s/iifname != \"br-lan\"/iifname != \"$LAN_IF\"/g" $D/nft.conf 2>/dev/null
echo "[✓] LAN: $LAN_IP on $LAN_IF"

uci -q delete firewall.mihomo_proxy 2>/dev/null
uci set firewall.mihomo_proxy=rule
uci set firewall.mihomo_proxy.name='Allow-DinoClash'
uci set firewall.mihomo_proxy.src='lan'
uci add_list firewall.mihomo_proxy.proto='tcp'
uci add_list firewall.mihomo_proxy.proto='udp'
uci set firewall.mihomo_proxy.dest_port='7890 7892 9595 1053'
uci set firewall.mihomo_proxy.target='ACCEPT'
uci commit firewall
/etc/init.d/firewall restart 2>/dev/null || true

# ═══════════════════════════════════════════════
# 🚀 SPEED BOOST - TCP Optimization (Auto)
# ═══════════════════════════════════════════════
echo "[*] Applying speed boost..."

# Apply now
sysctl -w net.ipv4.tcp_fastopen=3 >/dev/null 2>&1
sysctl -w net.core.rmem_max=16777216 >/dev/null 2>&1
sysctl -w net.core.wmem_max=16777216 >/dev/null 2>&1
sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216" >/dev/null 2>&1
sysctl -w net.ipv4.tcp_wmem="4096 87380 16777216" >/dev/null 2>&1
sysctl -w net.core.netdev_max_backlog=5000 >/dev/null 2>&1
sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1
sysctl -w net.ipv4.tcp_mtu_probing=1 >/dev/null 2>&1

# Make permanent (survives reboot)
cat > /etc/sysctl.d/99-dinoclash-speed.conf << 'SYSCTLEOF'
# DinoClash Speed Boost - Auto Applied
net.ipv4.tcp_fastopen=3
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 87380 16777216
net.core.netdev_max_backlog=5000
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_mtu_probing=1
SYSCTLEOF

# Auto-boost mihomo priority at boot
cat > /etc/rc.d/S99mihomo-boost << 'BOOSTEOF'
#!/bin/sh
sleep 30
PID=$(pgrep -f mihomo | head -1)
[ -n "$PID" ] && renice -n -10 -p $PID 2>/dev/null && ionice -c 1 -n 0 -p $PID 2>/dev/null
BOOSTEOF
chmod +x /etc/rc.d/S99mihomo-boost 2>/dev/null

echo "[✓] Speed boost applied (persistent)"

rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

echo ""
echo "═══════════════════════════════════════"
echo "🦕 DinoClash Installed Successfully!"
echo ""
echo "   ⚠️  Service is STOPPED (safe mode)"
echo "   Internet works normally."
echo ""
echo "   🚀 Speed Boost: ACTIVE (persistent)"
echo "      - TCP Fast Open"
echo "      - Buffer optimization"
echo "      - Auto priority boost"
echo ""
echo "   🌐 LuCI Panel: http://$LAN_IP"
echo "                  → Services → DinoClash 🦕"
echo "   📊 Dashboard:  http://$LAN_IP:9595/ui"
echo "   🔑 Secret:     flclash123"
echo ""
echo "   📄 Next Steps:"
echo "      1. Open LuCI Panel"
echo "      2. Upload YAML config"
echo "      3. Auto-Bypass will turn ON automatically"
echo "      4. Enjoy fast speed! 🚀"
echo ""
echo "═══════════════════════════════════════"
echo "🦕 DinoClash by Jahid Hasan Shuvo"
echo "═══════════════════════════════════════"
