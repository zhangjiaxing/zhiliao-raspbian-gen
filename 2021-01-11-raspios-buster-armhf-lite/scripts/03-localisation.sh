#!/bin/bash

# systemd-firstboot

chroot "${ROOTDIR}" /bin/bash <<EOF

# keyboard layout
\cp /etc/default/keyboard /etc/default/keyboard.back
sed -i 's/XKBLAYOUT="gb"/XKBLAYOUT="us"/g' /etc/default/keyboard
setupcon 2> /dev/null


# locale
sed -i 's/^en_GB.UTF-8 UTF-8//g' /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
localectl set-locale LANG=zh_CN.UTF-8 2> /dev/null


## timezone
#timedatectl set-timezone Asia/Shanghai
#timedatectl set-ntp true
#systemctl enable ntp


# Wi-fi Country
sed -i "s/^country=.*/country=CN/g" /etc/wpa_supplicant/wpa_supplicant.conf
sed -i "s/^REGDOMAIN=.*/REGDOMAIN=CN/g" /etc/default/crda

# avahi-daemon
sed -i "s/^publish-workstation=no/publish-workstation=yes/g" /etc/avahi/avahi-daemon.conf

EOF

