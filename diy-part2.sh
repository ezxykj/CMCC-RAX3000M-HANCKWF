#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 修改IP(B类地址)和主机名
sed -i 's/192.168.1.1/192.168.18.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.18.1/g' package/base-files/files/bin/config_generate
#sed -i 's/255.255.255.0/255.0.0.0/g' package/base-files/files/bin/config_generate
# sed -i 's/ImmortalWrt/HOME/g' package/base-files/files/bin/config_generate

# 修改登录密码为ezxykj
sed -i 's/root::0:0:99999:7:::/root:$1$iZM.01X5$xfeRwcqbhN\/60\/2SUPwDc\/:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 更改IP后TTYD不能访问以及外网访问
#sed -i '/${interface:+-i $interface}/s/^/#/' feeds/packages/utils/ttyd/files/ttyd.init   //此处屏蔽后，与ipv6冲突
#sed -i '/@lan/d' feeds/packages/utils/ttyd/files/ttyd.config
#sed -i "$ a\ \toption ipv6 '1'" feeds/packages/utils/ttyd/files/ttyd.config

#修改wifi名称（mtwifi-cfg）
sed -i 's/ImmortalWrt-2.4G/AP-2.4G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/ImmortalWrt-5G/AP-5G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# 添加openclash
rm -rf package/feeds/luci/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-openclash
mkdir package/openclash
cd package/openclash
git init
git remote add origin https://github.com/vernesong/OpenClash.git
git config core.sparsecheckout true
echo "luci-app-openclash" >> .git/info/sparse-checkout
git pull --depth 1 origin master
git branch --set-upstream-to=origin/master master
mv luci-app-openclash ../
cd ../../
rm -rf package/openclash

# 修改frpc
#git clone https://github.com/kuoruan/openwrt-upx.git package/openwrt-upx
rm -rf feeds/packages/lang/golang
mv files/golang feeds/packages/lang/
rm -rf feeds/packages/net/frp
mv files/frp/frp feeds/packages/net/
rm -rf feeds/luci/applications/luci-app-frpc
rm -rf feeds/luci/applications/luci-app-frps
mv files/frp/luci-app-frpc feeds/luci/applications/
mv files/frp/luci-app-frps feeds/luci/applications/
#chmod -R 755 feeds/luci/applications/luci-app-frpc/
#sed -i '/PKG_VERSION:=/c\PKG_VERSION:=0.61.2' feeds/packages/net/frp/Makefile   
#sed -i '/PKG_HASH:=/c\PKG_HASH:=19600d944e05f7ed95bac53c18cbae6ce7eff859c62b434b0c315ca72acb1d3c' feeds/packages/net/frp/Makefile 

# 修改appfilter->oaf
#rm -rf feeds/luci/applications/luci-app-appfilter
#git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# 添加cmcc-rax3000m-256m
mv files/mt7981-cmcc-rax3000m-256m.dts target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/
rm -rf target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/mt7981-cmcc-rax3000m.dtsi
mv files/mt7981-cmcc-rax3000m.dtsi target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/
sed -i '/^TARGET_DEVICES += cmcc_rax3000m$/a\
\
define Device/cmcc_rax3000m-256m \
  DEVICE_VENDOR := CMCC \
  DEVICE_MODEL := RAX3000M NAND 256M \
  DEVICE_DTS := mt7981-cmcc-rax3000m-256m \
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek \
  DEVICE_PACKAGES := $(MT7981_USB_PKGS) luci-app-ksmbd luci-i18n-ksmbd-zh-cn ksmbd-utils \
  SUPPORTED_DEVICES := cmcc,rax3000m \
  UBINIZE_OPTS := -E 5 \
  BLOCKSIZE := 128k \
  PAGESIZE := 2048 \
  IMAGE_SIZE := 240128k \
  KERNEL_IN_UBI := 1 \
  IMAGES += factory.bin \
  IMAGE/factory.bin := append-ubi | check-size $$$$(IMAGE_SIZE) \
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata \
endef \
TARGET_DEVICES += cmcc_rax3000m-256m
' target/linux/mediatek/image/mt7981.mk

# 添加luci-app-lucky
git clone  https://github.com/gdy666/luci-app-lucky.git package/luci-app-lucky

# 添加网易云unblockneteasemusic
rm -rf feeds/luci/applications/luci-app-unblockneteasemusic
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic
#sed -i 's/+node//g' package/luci-app-unblockneteasemusic/Makefile

#打包unblockneteasemusic的core核心
NAME=$"package/luci-app-unblockneteasemusic/root/usr/share/unblockneteasemusic" && mkdir -p $NAME/core
echo "$(curl -s 'https://api.github.com/repos/UnblockNeteaseMusic/server/commits?sha=enhanced&path=precompiled' | jq -r '.[0].sha')" > "$NAME/core_local_ver"
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/app.js -o $NAME/core/app.js
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/bridge.js -o $NAME/core/bridge.js
#mv files/unm/ca.crt $NAME/core/ca.crt
#mv files/unm/server.crt $NAME/core/server.crt
#mv files/unm/server.key $NAME/core/server.key
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/ca.crt -o $NAME/core/ca.crt
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.crt -o $NAME/core/server.crt
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.key -o $NAME/core/server.key

#添加上网时间控制
rm -rf feeds/luci/applications/luci-app-timecontrol
git clone https://github.com/gaobin89/luci-app-timecontrol package/luci-app-timecontrol
sed -i '/$(eval $(call BuildPackage,$(PKG_NAME)))/s/^/#/' package/luci-app-timecontrol/luci-app-timecontrol/Makefile

# h3c_nx30_pro_112m分区
mv files/mt7981-h3c-nx30pro-112m.dts target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/
sed -i '/^TARGET_DEVICES += h3c_nx30pro$/a\
\
define Device/h3c_nx30pro-112m \
  DEVICE_VENDOR := H3C \
  DEVICE_MODEL := NX30PRO 112M \
  DEVICE_DTS := mt7981-h3c-nx30pro-112m \
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek \
  SUPPORTED_DEVICES := h3c,nx30pro \
  UBINIZE_OPTS := -E 5 \
  BLOCKSIZE := 128k \
  PAGESIZE := 2048 \
  IMAGE_SIZE := 114688k \
  KERNEL_IN_UBI := 1 \
  IMAGES += factory.bin \
  IMAGE/factory.bin := append-ubi | check-size $$$$(IMAGE_SIZE) \
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata \
endef \
TARGET_DEVICES += h3c_nx30pro-112m
' target/linux/mediatek/image/mt7981.mk
# 初始化接口(network)
# sed -i 's/h3c,nx30pro/*h3c,nx30pro*/g' target/linux/mediatek/mt7981/base-files/etc/board.d/02_network
