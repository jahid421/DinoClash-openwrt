![Stars](https://img.shields.io/github/stars/jahid421/DinoClash-openwrt?style=for-the-badge&logo=github)
![Forks](https://img.shields.io/github/forks/jahid421/DinoClash-openwrt?style=for-the-badge&logo=github)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
![OpenWrt](https://img.shields.io/badge/OpenWrt-21.02--25.x-blue?style=for-the-badge&logo=openwrt)

# 🦕 DinoClash for OpenWrt

**Lightweight, fast, and universal proxy panel for OpenWrt routers.**

A proxy panel with auto-bypass, custom LuCI interface, YAML upload with auto-optimization, video streaming support, and mobile DNS fix — works on ALL architectures and OpenWrt versions (v21 to v25+) without any device setup.

---

## ✨ Features

### 🚀 Core
- **Auto-bypass** — No device setup needed (Redirect Mode)
- **Universal** — x86_64, ARM64, ARMv7, MIPS, MIPSEL, RISC-V
- **Lightweight** — 25MB RAM, works on 128MB routers
- **Ultra Fast** — interval:120s, tolerance:20ms, lazy mode
- **Mihomo Core** — Same engine as FLClash

### 🎨 Panel
- **Custom LuCI Panel** — Services → DinoClash 🦕
- **YAML Upload** — Auto-optimized for speed on upload
- **Subscription URL** — Auto-download + optimize
- **Dashboard** — MetaCubeXD included
- **Proxy Sort** — Sorted by latency (fastest first)
- **Real-time Monitor** — Traffic, connections, logs
- **Mode Switch** — Rule / Global / Direct

### ⚡ Speed
- **Load Balancing** — consistent-hashing strategy
- **Lazy Mode** — Skip dead proxies automatically
- **Keep-alive** — 10s fast reconnect
- **Video Streaming** — QUIC redirect support
- **Mobile DNS Fix** — redir-host mode
- **Silent Logging** — Zero CPU overhead

### 🔧 Smart
- **Config Validation** — Test before apply
- **State Persistence** — Survives reboot (Start/Stop remembered)
- **Auto Architecture Detection** — No manual selection
- **Auto LAN Detection** — Works on any network
- **v21 to v25+ Support** — opkg and apk compatible
- **iptables + nftables** — Auto-detect firewall
- **Dual LuCI Support** — Lua (v21-v24) + ucode (v25+)

---

## 📊 Why DinoClash?

DinoClash is designed for routers with limited resources. It focuses on simplicity, speed, and universal compatibility.

| Feature | Details |
|---|---|
| **RAM** | ~25MB (great for 128MB routers) |
| **Boot** | 3-5 seconds |
| **Install** | One command |
| **YAML** | Auto-optimized on upload |
| **Video** | QUIC redirect support |
| **Mobile** | DNS optimized (redir-host) |
| **Validation** | Config tested before apply |
| **Versions** | OpenWrt v21 to v25+ |
| **Architectures** | All (x86, ARM, MIPS, RISC-V) |
| **Package Managers** | opkg (v21-v24) + apk (v25+) |

---

## 📋 Requirements

| Component | Minimum | Recommended |
|---|---|---|
| RAM | 128MB | 256MB+ |
| Storage | 32MB (USB extroot) | 64MB+ |
| CPU | 500MHz single-core | 880MHz+ dual-core |
| OpenWrt | 21.02 | 23.05+ |

---

## 🎯 Supported Devices

| Architecture | Example Devices |
|---|---|
| **x86_64** | VMware, VirtualBox, Mini PC (N100/N5105) |
| **ARM64** | Xiaomi AX3200, NanoPi R2S/R4S/R5S, GL.iNet MT3000 |
| **ARMv7** | IPQ40xx, MT7622 devices |
| **MIPSEL** | MikroTik RB750Gr3, Xiaomi 4A Gigabit, MT7621 |
| **MIPS** | TP-Link Archer C7, Atheros AR9344 |
| **RISC-V** | Newer boards |

---

## 🚀 Installation

### OpenWrt v21 - v24 (opkg):

    opkg update && opkg install curl ca-bundle ca-certificates && curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/install.sh | sh

### OpenWrt v25+ (apk):

    apk update && apk add curl ca-bundle ca-certificates && curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/install.sh | sh

### Universal (wget — works on all versions):

    wget -qO- https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/install.sh | sh

### After Installation:

1. **LuCI Panel:** `http://your-router-ip` → Services → DinoClash 🦕
2. **Dashboard:** `http://your-router-ip:9595/ui`
3. **Secret:** `flclash123`
4. **Upload your YAML config from LuCI panel — done!**
5. **Turn OFF manual proxy on all devices!**

---

## 📱 Usage

### Step 1: Open LuCI Panel

    http://your-router-ip → Services → DinoClash 🦕

### Step 2: Upload YAML Config

- Click **"Upload YAML Config"**
- Select your config file (.yaml / .yml)
- Click **"Upload & Apply"**
- Config auto-optimized and applied!

### Step 3: Done!

- All devices on your network auto-use proxy
- No manual setup on any device
- Proxy sorted by latency (fastest first)

---

## 🎨 Panel Features

### Overview Tab
- Start / Stop / Restart service
- Auto-Bypass toggle (ON/OFF)
- Upload YAML config
- Subscription URL support
- Mode switch (Rule/Global/Direct)
- Real-time traffic graph
- Memory usage display
- Quick actions (Update GeoIP, Flush DNS, Open Dashboard)

### Proxy Tab
- All proxy groups displayed
- Nodes sorted by latency (fastest first ⚡)
- Test all delays with one click
- Search proxies by name
- Click to select active node

### Config Tab
- Full YAML editor
- Save & auto-restart

### Connections Tab
- Live active connections
- Filter by host name
- Close individual or all connections

### Log Tab
- Real-time log streaming
- Filter by level (Info / Warning / Error)
- Clear logs

---

## 🔧 Useful Commands

### Check Status

    pgrep -f mihomo && echo "Running" || echo "Stopped"

### Restart Service

    /etc/init.d/mihomo restart

### View Logs

    logread | grep mihomo | tail -20

### Enable Auto-Bypass

    echo "1" > /etc/mihomo/transparent && /etc/init.d/mihomo restart

### Disable Auto-Bypass

    echo "0" > /etc/mihomo/transparent && /etc/init.d/mihomo restart

### Full Update (all files from GitHub)

    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo.lua -o /usr/lib/lua/luci/controller/mihomo.lua
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/main.htm -o /usr/lib/lua/luci/view/mihomo/main.htm
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo.init -o /etc/init.d/mihomo
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo-api -o /www/cgi-bin/mihomo-api
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo-cfg -o /www/cgi-bin/mihomo-cfg
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo-sub -o /www/cgi-bin/mihomo-sub
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/nft.conf -o /etc/mihomo/nft.conf
    chmod +x /etc/init.d/mihomo /www/cgi-bin/mihomo-*
    rm -rf /tmp/luci-*
    /etc/init.d/rpcd restart && /etc/init.d/uhttpd restart && /etc/init.d/mihomo restart

---

## 🗑️ Uninstall

    /etc/init.d/mihomo stop
    /etc/init.d/mihomo disable
    rm -f /usr/bin/mihomo /etc/init.d/mihomo
    rm -rf /etc/mihomo /usr/lib/lua/luci/view/mihomo
    rm -f /usr/lib/lua/luci/controller/mihomo.lua
    rm -f /usr/share/luci/menu.d/luci-app-dinoclash.json
    rm -f /www/cgi-bin/mihomo-*
    nft delete table inet mihomo 2>/dev/null
    uci -q delete firewall.mihomo_proxy
    uci set dhcp.@dnsmasq[0].noresolv='0'
    uci -q delete dhcp.@dnsmasq[0].server
    uci commit dhcp firewall
    /etc/init.d/dnsmasq restart
    /etc/init.d/firewall restart
    rm -rf /tmp/luci-*
    /etc/init.d/rpcd restart && /etc/init.d/uhttpd restart

---

## ⚠️ OpenClash Users

Cannot run both DinoClash and OpenClash simultaneously due to port conflicts.

Before installing DinoClash:

    /etc/init.d/openclash stop
    /etc/init.d/openclash disable

---

## 🐛 Troubleshooting

### LuCI menu not showing?

    # v21-v24
    opkg install luci-compat luci-lib-ipkg
    
    # v25+
    apk add luci-compat
    
    # Then
    rm -rf /tmp/luci-*
    /etc/init.d/uhttpd restart && /etc/init.d/rpcd restart

### DinoClash won't start?

    /usr/bin/mihomo -v
    /usr/bin/mihomo -d /etc/mihomo -t
    logread | grep mihomo | tail -20

### Internet breaks after enabling auto-bypass?

    echo "0" > /etc/mihomo/transparent
    /etc/init.d/mihomo restart
    nft delete table inet mihomo 2>/dev/null

### Wrong architecture detected?

    uname -m
    cat /etc/openwrt_release | grep ARCH

---


## 🙏 Credits

- **[MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo)** — Proxy core engine
- **[MetaCubeX/metacubexd](https://github.com/MetaCubeX/metacubexd)** — Web dashboard
- **[vernesong/OpenClash](https://github.com/vernesong/OpenClash)** — Redirect mode inspiration
- **[chen08209/FlClash](https://github.com/chen08209/FlClash)** — UI inspiration

---

## 👨‍💻 Developer

**Jahid Hasan Shuvo**

[![Instagram](https://img.shields.io/badge/Instagram-@crazy__boy__jahid-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/crazy_boy_jahid)
[![GitHub](https://img.shields.io/badge/GitHub-@jahid421-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/jahid421)

---

## ⭐ Support

If DinoClash helped you, please give it a ⭐ star on GitHub!

**Share with your friends who use OpenWrt routers!**

---

## 📄 License

MIT License — Free to use, modify, and distribute.

---

**Made with 🦕 for the OpenWrt community**
