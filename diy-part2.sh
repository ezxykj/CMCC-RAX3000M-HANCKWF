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
sed -i 's/192.168.6.1/10.0.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/255.255.255.0/255.0.0.0/g' package/base-files/files/bin/config_generate
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
#sed -i 's/ImmortalWrt-2.4G/XYKJ/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
#sed -i 's/ImmortalWrt-5G/XYKJ/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

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
git clone https://github.com/kuoruan/openwrt-upx.git package/openwrt-upx
rm -rf feeds/packages/lang/golang
mv files/golang feeds/packages/lang/
rm -rf feeds/packages/net/frp/*
mv files/Makefile feeds/packages/net/frp/
rm -rf feeds/luci/applications/luci-app-frpc
mv files/luci-app-frpc feeds/luci/applications/
chmod -R 755 feeds/luci/applications/luci-app-frpc/
sed -i '/PKG_VERSION:=/c\PKG_VERSION:=0.58.1' feeds/packages/net/frp/Makefile
sed -i '/PKG_HASH:=/c\PKG_HASH:=c6eabdc2bf39bdb4a7ab7794a4b2ad94be5e0cab50b6cc540a6431e61208b1e6' feeds/packages/net/frp/Makefile

# 修改appfilter->oaf
rm -rf feeds/luci/applications/luci-app-appfilter
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# 添加cmcc-rax3000m-256m
mv files/mt7981-cmcc-rax3000m-256m.dts target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/
mv files/mt7981-cmcc-rax3000m-256m.dtsi target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/
sed -i '/^TARGET_DEVICES += cmcc_rax3000m$/a\
\ndefine Device/cmcc_rax3000m-256m\
  DEVICE_VENDOR := CMCC\
  DEVICE_MODEL := RAX3000M NAND 256m\
  DEVICE_DTS := mt7981-cmcc-rax3000m-256m\
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek\
  DEVICE_PACKAGES := $(MT7981_USB_PKGS) luci-app-ksmbd luci-i18n-ksmbd-zh-cn ksmbd-utils\
  SUPPORTED_DEVICES := cmcc,rax3000m\
  UBINIZE_OPTS := -E 5\
  BLOCKSIZE := 128k\
  PAGESIZE := 2048\
  IMAGE_SIZE := 240128k\
  KERNEL_IN_UBI := 1\
  IMAGES += factory.bin\
  IMAGE/factory.bin := append-ubi | check-size $$$$(IMAGE_SIZE)\
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata\
endef\
TARGET_DEVICES += cmcc_rax3000m-256m
' target/linux/mediatek/image/mt7981.mk
