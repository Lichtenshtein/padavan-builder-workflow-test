#!/usr/bin/env bash
set -e
# Отключение log wireguard debug
sed -i 's/func_enable_kernel_param "CONFIG_WIREGUARD_DEBUG"/func_disable_kernel_param "CONFIG_WIREGUARD_DEBUG"/' padavan-ng/trunk/build_firmware.sh

# Change building server timezone 
# ln -snf /usr/share/zoneinfo/Europe/Astrakhan /etc/localtime
# apt update
# DEBIAN_FRONTEND=noninteractive apt install tzdata -y

# Wi-Fi Country Code
sed -i 's/UA/RU/g' padavan-ng/trunk/user/shared/defaults.h

# NTP servers
sed -i 's/pool.ntp.org/ru.pool.ntp.org/' padavan-ng/trunk/user/shared/defaults.h
sed -i 's/time.in.ua/time.nist.gov/' padavan-ng/trunk/user/shared/defaults.h

# Настройка BusyBox (включение netcat)
busybox_cfg="padavan-ng/trunk/configs/boards/busybox.config"

if [[ -f "$busybox_cfg" ]]; then
  busybox_enable() {
    sed -i "s/# $1 is not set/1=y/" "$busybox_cfg"
  }

  busybox_enable CONFIG_NC
  busybox_enable CONFIG_NC_EXTRA
  busybox_enable CONFIG_NC_110_COMPAT

  if ! grep -q "^CONFIG_NETCAT=y" "$busybox_cfg"; then
    echo "CONFIG_NETCAT=y" >> "$busybox_cfg"
  fi
else
  echo "Внимание: файл $busybox_cfg не найден!"
fi
