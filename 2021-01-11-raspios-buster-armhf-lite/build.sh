#!/bin/bash

cd `dirname $0`

source ./functions.sh

if [[ "${EUID}" != "0" ]] ; then
    echo "Please run this as root."
    exit
fi

export OUTPUTDIR="./output"
export IMG="./image/2021-01-11-raspios-buster-armhf-lite.img"
export BUILD_TIME=`date '+%Y-%m-%d %T'`
export BUILD_DATE=`date '+%Y-%m-%d'`
export ROOTDIR="/mnt/"

if [ ! -f "${IMG}" ]; then
    echo "Image file not found ..."
    exit
fi

mkdir -p "${OUTPUTDIR}"
echo "$BUILD_TIME" >| "${OUTPUTDIR}"/build-time.txt

#-------------- Begin 扩大镜像空间 --------------#
dd if=/dev/zero of="${IMG}" oflag=append conv=notrunc status=progress bs=1M count=500

# mount image
modprobe loop
losetup -D

export LOOPDEV=`losetup --show -Pf "${IMG}" 2>/dev/null`
cat new.sfdisk | sfdisk "${LOOPDEV}"
e2fsck -f "${LOOPDEV}p2"
resize2fs "${LOOPDEV}p2"

#-------------- 扩大镜像空间 End --------------#
echo 按任意键继续. . .
read

mount "${LOOPDEV}p2" "$ROOTDIR"
mount "${LOOPDEV}p1" "$ROOTDIR"/boot

chroot "${ROOTDIR}" /bin/bash <<EOF
mount -t tmpfs -o size=512M tmpfs /tmp
mount -t proc proc /proc
mount --bind /etc/resolv.conf /etc/resolv.conf
mount -o remount,bind,ro /etc/resolv.conf /etc/resolv.conf
EOF

install --mode=755 ./functions.sh "$ROOTDIR"/usr/local/bin/

export LANG=C
# run script
source ./scripts/01-fix-rootfs.sh
source ./scripts/02-enable-ssh.sh
source ./scripts/03-localisation.sh
source ./scripts/05-user-hostname.sh
source ./scripts/06-misc.sh
source ./scripts/07-disk-protect.sh
source ./scripts/08-install-package.sh
source ./scripts/09-fs-layout.sh
source ./scripts/14-clean-up.sh

source ./scripts/99-manual-edit.sh


fuser -k /mnt


chroot "${ROOTDIR}" /bin/bash <<EOF
umount /etc/resolv.conf
umount /proc
umount /tmp
EOF

# umount image
umount /mnt/boot
umount /mnt
sync
losetup -D
sync


# output
mv "${IMG}" "${OUTPUTDIR}/xluf-zhiliao-${BUILD_DATE}.img"
echo "Success... 恭喜镜像编译完成！"
echo "编译后的镜像位置:${OUTPUTDIR}/xluf-zhiliao-${BUILD_DATE}.img"

