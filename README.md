# 🦕 DinoClash for OpenWrt

Lightweight proxy panel for OpenWrt routers with auto-bypass. Custom LuCI panel, YAML upload, and OpenClash-style redirect mode — works on all architectures without any device setup.

## ✨ Features

- Auto-bypass (No device setup needed - Redirect Mode)
- Universal (x86_64, ARM64, ARMv7, MIPS, MIPSEL)
- Lightweight (30MB RAM, works on 128MB routers)
- Custom LuCI Panel (Services → DinoClash)
- YAML Upload (Auto-optimized for speed)
- Dashboard (MetaCubeXD included)
- Mihomo Core (Fast engine)
- Real-time Monitor (Traffic, connections, logs)
- Mode Switch (Rule/Global/Direct)
- Auto architecture detection
- Mobile DNS optimized
- State persistence (reboot safe)

## 🚀 Installation

SSH into your router and run:

    opkg update && opkg install curl ca-bundle ca-certificates && curl -sL https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/install.sh | sh

Or with wget:

    wget -qO- https://raw.githubusercontent.com/jahid421/DinoClash-openwrt/main/install.sh | sh

After installation:
- LuCI: `http://your-router-ip` → Services → DinoClash
- Dashboard: `http://your-router-ip:9595/ui`
- Secret: `flclash123`

Upload your YAML config from LuCI panel — done!

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

## 🙏 Credits

- [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) - Proxy core
- [MetaCubeX/metacubexd](https://github.com/MetaCubeX/metacubexd) - Dashboard
- [vernesong/OpenClash](https://github.com/vernesong/OpenClash) - Redirect mode inspiration
- [chen08209/FlClash](https://github.com/chen08209/FlClash) - UI inspiration

## 👨‍💻 Developer

**Jahid Hasan Shuvo**
- Instagram: [@crazy_boy_jahid](https://instagram.com/crazy_boy_jahid)
- GitHub: [@jahid421](https://github.com/jahid421)

---

**Made with 🦕 for the OpenWrt community**
