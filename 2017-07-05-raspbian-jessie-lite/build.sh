#!/bin/bash

cd `dirname $0`

OUTPUTDIR="./output"

IMG="./image/2017-07-05-raspbian-jessie-lite.img"

if [[ "${EUID}" != "0" ]] ; then
    echo "Please run this as root."
    exit
fi

if [ ! -f "${IMG}" ]; then
    echo "Image file not found ..."
    exit
fi

mkdir -p "${OUTPUTDIR}"

# umount /mnt/*
# findmnt -lno target | grep '^/mnt' | xargs umount


# mount image
modprobe loop
losetup -D

LOOPDEV=`losetup --show -Pf "${IMG}" 2>/dev/null`

mount "${LOOPDEV}p2" /mnt
mount "${LOOPDEV}p1" /mnt/boot
ROOTDIR="/mnt/"


chroot "${ROOTDIR}" /bin/bash <<EOF
mount --bind /etc/resolv.conf /etc/resolv.conf
mount -o remount,bind,ro /etc/resolv.conf /etc/resolv.conf
mount -t proc proc /proc
mount -t tmpfs -o size=512M tmpfs /tmp
EOF


# run script
source ./scripts/01-rootfs.sh
source ./scripts/02-enable-ssh.sh
source ./scripts/03-localisation.sh
source ./scripts/05-user-hostname.sh
source ./scripts/06-misc.sh
source ./scripts/07-disk-protect.sh
source ./scripts/08-install-package.sh
source ./scripts/09-fs-layout.sh


fuser -k /mnt


chroot "${ROOTDIR}" /bin/bash <<EOF
umount /tmp
umount /proc
umount /etc/resolv.conf
EOF

umount /mnt/etc/resolv.conf

# umount image
umount /mnt/boot
umount /mnt
sync
losetup -D
sync


# output
mv "${IMG}" "${OUTPUTDIR}/"

echo build finish

