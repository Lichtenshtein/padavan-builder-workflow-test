#!/usr/bin/env bash

# Отключение log wireguard debug
sed -i 's/func_enable_kernel_param "CONFIG_WIREGUARD_DEBUG"/func_disable_kernel_param "CONFIG_WIREGUARD_DEBUG"/' padavan-ng/trunk/build_firmware.sh

# Change building server timezone 
ln -snf /usr/share/zoneinfo/Europe/Astrakhan /etc/localtime
apt update
DEBIAN_FRONTEND=noninteractive apt install tzdata -y

# Wi-Fi Country Code
sed -i 's/UA/RU/g' padavan-ng/trunk/user/shared/defaults.h

# NTP servers
sed -i 's/pool.ntp.org/ru.pool.ntp.org/' padavan-ng/trunk/user/shared/defaults.h
sed -i 's/time.in.ua/time.nist.gov/' padavan-ng/trunk/user/shared/defaults.h

# Настройка версии прошивки
sed -i 's/^FIRMWARE_ROOTFS_VER.*/FIRMWARE_ROOTFS_VER=3.9L/' padavan-ng/trunk/versions.inc
sed -i 's/^FIRMWARE_BUILDS_VER.*/FIRMWARE_BUILDS_VER=102/' padavan-ng/trunk/versions.inc

# Установка последней версии zapret
ZAPRET_REPO="https://github.com/bol-van/zapret.git"
ZAPRET_TAGS=$(git ls-remote --tags "$ZAPRET_REPO" | awk '{print $2}' | sed 's/refs\/tags\///g')
ZAPRET_VER=$(echo "$ZAPRET_TAGS" | sort -V | tail -n 1 | sed 's/^.//')
sed -i "s/^SRC_VER.*/SRC_VER = $ZAPRET_VER/g" padavan-ng/trunk/user/nfqws/Makefile
cd padavan-ng/trunk/user/nfqws
curl -o patches/firmware-specific.patch https://raw.githubusercontent.com/Lichtenshtein/padavan-builder-workflow-test/refs/heads/xiaomi-mi-mini/firmware-specific.patch
find . -maxdepth 1 -not -name Makefile -not -name patches -print0 | xargs -0 rm -rf --

busybox_cfg="padavan-ng/trunk/configs/boards/busybox.config"

busybox_enable() {
  sed -i "s/\# $1 is not set/$1=y/" $busybox_cfg
}

busybox_enable CONFIG_NC
busybox_enable CONFIG_NC_EXTRA
busybox_enable CONFIG_NC_110_COMPAT

echo "CONFIG_NETCAT=y" >> padavan-ng/trunk/configs/boards/busybox.config
