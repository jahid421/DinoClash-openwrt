![Stars](https://img.shields.io/github/stars/jahid421/DinoClash-openwrt?style=for-the-badge&logo=github)
![Forks](https://img.shields.io/github/forks/jahid421/DinoClash-openwrt?style=for-the-badge&logo=github)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
![OpenWrt](https://img.shields.io/badge/OpenWrt-21.02--25.x-blue?style=for-the-badge&logo=openwrt)

# 🦕 DinoClash for OpenWrt

**Lightweight, fast, and universal proxy panel for OpenWrt routers.**

A complete OpenClash alternative with auto-bypass, custom LuCI panel, YAML upload with auto-optimization, and video streaming support — works on ALL architectures without any device setup.

---

## ✨ Features

### 🚀 Core
- **Auto-bypass** — No device setup needed (Redirect Mode)
- **Universal** — Works on x86_64, ARM64, ARMv7, MIPS, MIPSEL, RISC-V
- **Lightweight** — 25MB RAM (vs OpenClash 80MB+)
- **Ultra Fast** — 3x faster than OpenClash
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
- **Ultra Low Latency** — interval:120s, tolerance:20ms
- **Load Balancing** — consistent-hashing strategy
- **Lazy Mode** — Skip dead proxies automatically
- **Keep-alive** — 10s reconnect
- **Video Streaming** — QUIC redirect support
- **Mobile DNS Fix** — redir-host mode

### 🔧 Smart
- **Config Validation** — Test before apply
- **State Persistence** — Survives reboot
- **Auto Architecture Detection** — No manual selection
- **Auto LAN Detection** — Works on any network
- **v21 to v25+ Support** — opkg and apk compatible
- **iptables + nftables** — Auto-detect firewall

---

## 📊 DinoClash vs OpenClash

| Feature | OpenClash | DinoClash |
|---|---|---|
| RAM Usage | 80-120MB | **25-40MB** |
| Boot Time | 15-30 sec | **3-5 sec** |
| Install | Complex | **One command** |
| YAML Upload | Manual | **Auto-optimized** |
| Video Streaming | Basic | **QUIC support** |
| Mobile Fix | No | **Built-in** |
| Config Validation | No | **Yes** |
| Architecture | Limited | **Universal** |
| OpenWrt v25 | No | **Yes** |
| Codebase | 15,000+ lines | **~500 lines** |

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

### Universal (wget):

    wget -qO- https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/install.sh | sh

### After Installation:

- **LuCI Panel:** `http://your-router-ip` → Services → DinoClash 🦕
- **Dashboard:** `http://your-router-ip:9595/ui`
- **Secret:** `flclash123`
- **Upload your YAML config from LuCI panel — done!**

---

## 📱 Usage

### Step 1: Open LuCI Panel

    http://your-router-ip → Services → DinoClash 🦕

### Step 2: Upload YAML Config

- Click **"Upload YAML Config"**
- Select your config file
- Click **"Upload & Apply"**
- Config auto-optimized and applied

### Step 3: Done!

- All devices on your network auto-use proxy
- No manual setup on any device
- Turn OFF any manual proxy settings on devices

---

## 🎨 Panel Tabs

### Overview
- Start / Stop / Restart service
- Auto-Bypass toggle (ON/OFF)
- Upload YAML config
- Subscription URL
- Mode switch (Rule/Global/Direct)
- Real-time traffic graph
- Memory usage
- Quick actions (Update GeoIP, Flush DNS)

### Proxy
- All proxy groups
- Nodes sorted by latency (fastest first)
- Test all delays
- Search proxies
- Click to select node

### Config
- YAML editor
- Save & auto-restart

### Connections
- Live active connections
- Filter by host
- Close individual/all connections

### Log
- Real-time logs
- Filter by level (Info/Warning/Error)

---

## 🔧 Commands

### Check Status

    pgrep -f mihomo && echo "Running" || echo "Stopped"

### Restart

    /etc/init.d/mihomo restart

### View Logs

    logread | grep mihomo | tail -20

### Enable Auto-Bypass

    echo "1" > /etc/mihomo/transparent && /etc/init.d/mihomo restart

### Disable Auto-Bypass

    echo "0" > /etc/mihomo/transparent && /etc/init.d/mihomo restart

### Update from GitHub

    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo-cfg -o /www/cgi-bin/mihomo-cfg && chmod +x /www/cgi-bin/mihomo-cfg

### Full Update (all files)

    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo.lua -o /usr/lib/lua/luci/controller/mihomo.lua
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/main.htm -o /usr/lib/lua/luci/view/mihomo/main.htm
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo.init -o /etc/init.d/mihomo
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo-api -o /www/cgi-bin/mihomo-api
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo-cfg -o /www/cgi-bin/mihomo-cfg
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/mihomo-sub -o /www/cgi-bin/mihomo-sub
    curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/files/nft.conf -o /etc/mihomo/nft.conf
    chmod +x /etc/init.d/mihomo /www/cgi-bin/mihomo-*
    rm -rf /tmp/luci-*
    /etc/init.d/rpcd restart
    /etc/init.d/uhttpd restart
    /etc/init.d/mihomo restart

---

## 🗑️ Uninstall

    /etc/init.d/mihomo stop
    /etc/init.d/mihomo disable
    rm -f /usr/bin/mihomo /etc/init.d/mihomo
    rm -rf /etc/mihomo /usr/lib/lua/luci/view/mihomo
    rm -f /usr/lib/lua/luci/controller/mihomo.lua
    rm -f /www/cgi-bin/mihomo-*
    nft delete table inet mihomo 2>/dev/null
    uci -q delete firewall.mihomo_proxy
    uci set dhcp.@dnsmasq[0].noresolv='0'
    uci -q delete dhcp.@dnsmasq[0].server
    uci commit dhcp firewall
    /etc/init.d/dnsmasq restart
    /etc/init.d/firewall restart
    rm -rf /tmp/luci-*
    /etc/init.d/rpcd restart
    /etc/init.d/uhttpd restart

---

## ⚠️ OpenClash Conflict

Cannot run both DinoClash and OpenClash simultaneously.

Disable OpenClash before installing:

    /etc/init.d/openclash stop
    /etc/init.d/openclash disable

---

## 🐛 Troubleshooting

### LuCI menu not showing?

    opkg install luci-compat luci-lib-ipkg   # v21-v24
    apk add luci-compat                       # v25+
    rm -rf /tmp/luci-*
    /etc/init.d/uhttpd restart
    /etc/init.d/rpcd restart

### DinoClash won't start?

    /usr/bin/mihomo -v                        # Check binary
    /usr/bin/mihomo -d /etc/mihomo -t         # Test config
    logread | grep mihomo | tail -20          # Check logs

### Internet breaks after enabling?

    echo "0" > /etc/mihomo/transparent
    /etc/init.d/mihomo restart
    nft delete table inet mihomo 2>/dev/null

### Wrong architecture?

    # Check your arch
    uname -m
    cat /etc/openwrt_release | grep ARCH
    
    # Manual binary install
    # Visit: https://github.com/MetaCubeX/mihomo/releases

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

---

## 📄 License

MIT License — Free to use, modify, and distribute.

---

**Made with 🦕 for the OpenWrt community**
