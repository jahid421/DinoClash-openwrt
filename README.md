# 🚀 FLClash for OpenWrt

Lightweight Mihomo (FLClash engine) with custom LuCI panel and auto-bypass for OpenWrt routers.

## Features

- ✅ **Auto-bypass** - All devices automatically use proxy (TUN mode)
- ✅ **Custom LuCI Panel** - Services → Mihomo
- ✅ **YAML Upload** - Upload your personal config
- ✅ **Subscription Support** - URL-based config download
- ✅ **MetaCubeXD Dashboard** - Full featured web UI
- ✅ **Real-time Monitoring** - Traffic, connections, logs
- ✅ **Multi-arch Support** - x86_64, arm64, armv7, mips, mipsel

## Requirements

- OpenWrt 23.05+
- Router with 128MB+ RAM
- `kmod-tun`, `kmod-nft-tproxy` (auto-installed)

## Installation

SSH into your router and run:

```bash
curl -sL https://raw.githubusercontent.com/jahid421/openwrt-flclash/main/install.sh | sh
```

## Usage
## Access LuCI Panel
http://your-router-ip → Services → MihomO


## Upload YAML Config
1. Open LuCI panel
2. Services → Mihomo → Overview
3. Click "Upload YAML" and select your config file
4. Auto-applied and restarted

## Toggle Transparent Proxy
Enable auto-bypass:
```bash
echo "1" > /etc/mihomo/transparent && /etc/init.d/mihomo restart
```
Disable:
```bash
echo "0" > /etc/mihomo/transparent && /etc/init.d/mihomo restart
```
