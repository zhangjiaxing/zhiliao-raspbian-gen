#!/bin/bash

mkdir -p /data

mkfs.ext4 /dev/mmcblk0p3
sync
sleep 2

e2label /dev/mmcblk0p3 data
sync
sleep 2

partprobe /dev/mmcblk0
partprobe
sleep 5

until mount -t ext4 -o data=journal LABEL=data /data; do
    sleep 1
done


echo "LABEL=data    /data       ext4    defaults,noatime,nodelalloc,auto_da_alloc,commit=1,data=ordered     0   3" >> /etc/fstab

touch /data/fake-hwclock.data

mkdir --mode=0700 -p /data/system-connections
\cp -f /etc/NetworkManager/system-connections/* /data/system-connections
chmod 0600 /data/system-connections/*

\rm -rf /etc/cron.d/xlxd-fs-layout
\rm -rf /root/xlxd-fs-layout-script.sh
\rm -rf /root/init_resize.sh

