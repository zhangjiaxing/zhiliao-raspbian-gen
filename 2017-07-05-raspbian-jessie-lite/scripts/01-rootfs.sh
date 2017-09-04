#!/bin/bash

sed -i 's/init=\/usr\/lib\/raspi-config\/init_resize.sh//g' "${ROOTDIR}"/boot/cmdline.txt
sed -i 's/root=PARTUUID=a8790229-02/root=LABEL=rootfs/g'    "${ROOTDIR}"/boot/cmdline.txt
# sed -i 's/root=PARTUUID=a8790229-02/root=/dev/mmcblk0p2/g'    "${ROOTDIR}"/boot/cmdline.txt
sed -i 's/ quiet / /g'    "${ROOTDIR}"/boot/cmdline.txt

sed -i s/PARTUUID=a8790229-01/LABEL=boot/g    "${ROOTDIR}"/etc/fstab
sed -i s/PARTUUID=a8790229-02/LABEL=rootfs/g  "${ROOTDIR}"/etc/fstab

e2label "${LOOPDEV}p2" "rootfs"

