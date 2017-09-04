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

mount -t ext4 LABEL=data /data

echo "LABEL=data    /data       ext4    defaults,noatime    0   3" >> /etc/fstab


\rm -rf /etc/cron.d/zhiliao-fs-layout
\rm -rf /root/zhiliao-fs-layout-script.sh
\rm -rf /root/init_resize.sh

