#!/bin/bash

mkfs.ext4 /dev/mmcblk0p3
mkfs.ext4 /dev/mmcblk0p4
sync

e2label /dev/mmcblk0p3 unused
e2label /dev/mmcblk0p4 data

sync
partprobe /dev/mmcblk0
partprobe
sleep 5

mount -t ext4 -o data=journal LABEL=data /data

echo "LABEL=data    /data       ext4    defaults,noatime,data=journal     0   3" >> /etc/fstab

touch /data/fake-hwclock.data

mkdir --mode=0700 -p /data/system-connections
\cp -f /etc/NetworkManager/system-connections/* /data/system-connections
chmod 0600 /data/system-connections/*

\rm -rf /etc/cron.d/xlxd-fs-layout
\rm -rf /root/xlxd-fs-layout-script.sh
\rm -rf /root/init_resize.sh

