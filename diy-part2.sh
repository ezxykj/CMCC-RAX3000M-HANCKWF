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

# Modify default IP
sed -i 's/192.168.1.1/10.10.10.13/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/10.10.10.13/g' package/base-files/files/bin/config_generate

# change the login password

sed -i 's/root::0:0:99999:7:::/root:$1$iZM.01X5$xfeRwcqbhN\/60\/2SUPwDc\/:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/ImmortalWrt/RAX3000M/g' package/base-files/files/bin/config_generate

#修改wifi名称（mtwifi-cfg）
sed -i 's/ImmortalWrt-2.4G/XYKJ/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/ImmortalWrt-5G/XYKJ/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
