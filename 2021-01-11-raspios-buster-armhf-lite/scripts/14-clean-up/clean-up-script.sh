#!/bin/bash

sleep 60

while [[ -f /etc/cron.d/script-run-once ]]; do
    sleep 10
done

sync
sleep 5

\rm -rf /root/git

touch /boot/xlxd/rootfs-protect
\rm /etc/cron.d/clean-up
\rm /root/clean-up-script.sh
sync

tune2fs -O read-only LABEL=rootfs
sync

sleep 5
sync

reboot

