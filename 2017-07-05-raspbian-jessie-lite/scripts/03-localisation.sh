#!/bin/bash

# systemd-firstboot

chroot "${ROOTDIR}" /bin/bash <<EOF

# keyboard layout
cp /etc/default/keyboard /etc/default/keyboard.back
sed -i 's/XKBLAYOUT="gb"/XKBLAYOUT="us"/g' /etc/default/keyboard
setupcon


# locale
# echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
# locale-gen
# localectl set-locale LANG=en_GB.UTF-8


# timezone
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true
systemctl enable ntp


# Wi-fi Country
sed -i "s/^country=.*/country=CN/g" /etc/wpa_supplicant/wpa_supplicant.conf

EOF

