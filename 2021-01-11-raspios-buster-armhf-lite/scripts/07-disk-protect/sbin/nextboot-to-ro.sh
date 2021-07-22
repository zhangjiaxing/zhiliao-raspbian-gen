#!/bin/bash

if [[ "${EUID}" != "0" ]] ; then
    echo "Please run this as root."
    exit
fi

bootflag=`findmnt /boot -no options | cut -d ',' -f1`

if [[ "${bootflag}" != "rw" ]] ; then
    mount -o remount,rw /boot
fi

mkdir -p /boot/xlxd
touch /boot/xlxd/rootfs-protect
tune2fs -O read-only LABEL=rootfs

