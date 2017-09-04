workdir=`pwd`

# swapoff
chroot "${ROOTDIR}" /bin/bash<<EOF

systemctl stop dphys-swapfile
systemctl disable dphys-swapfile
dphys-swapfile uninstall

EOF

install --mode=755 ./scripts/07-disk-protect/sbin/nextboot-to-ro.sh  "${ROOTDIR}"/usr/local/sbin/
install --mode=755 ./scripts/07-disk-protect/sbin/nextboot-to-rw.sh  "${ROOTDIR}"/usr/local/sbin/


# overlayfs
tempdir=`mktemp -d --suffix=.mkinitramfs`
pushd "${tempdir}"

mkdir -p ./initramfs/{bin,dev,lib,proc,sys}
/bin/busybox --install -s ./initramfs/bin
cp /bin/busybox ./initramfs/bin/

# mkdir -p initramfs/lib/modules/`uname -r`
# cp "${ROOTDIR}"/lib/modules/`uname -r`/modules.{builtin,order} initramfs/lib/modules/`uname -r`
# mkdir -p initramfs/lib/modules/`uname -r`/kernel/fs/overlayfs
# cp -a "${ROOTDIR}"/lib/modules/`uname -r`/kernel/fs/overlayfs/overlay.ko initramfs/lib/modules/`uname -r`/kernel/fs/overlayfs
# depmod -a --basedir initramfs

mkdir -p ./initramfs/lib/modules/{4.9.35+,4.9.35-v7+}
cp "${ROOTDIR}"/lib/modules/4.9.35+/modules.{builtin,order} ./initramfs/lib/modules/4.9.35+/
cp "${ROOTDIR}"/lib/modules/4.9.35-v7+/modules.{builtin,order} ./initramfs/lib/modules/4.9.35-v7+/
mkdir -p ./initramfs/lib/modules/{4.9.35+,4.9.35-v7+}/kernel/fs/overlayfs
cp -a "${ROOTDIR}"/lib/modules/4.9.35+/kernel/fs/overlayfs/overlay.ko ./initramfs/lib/modules/4.9.35+/kernel/fs/overlayfs
cp -a "${ROOTDIR}"/lib/modules/4.9.35-v7+/kernel/fs/overlayfs/overlay.ko ./initramfs/lib/modules/4.9.35-v7+/kernel/fs/overlayfs
depmod -a --basedir ./initramfs

install --mode=755 "${workdir}"/scripts/07-disk-protect/init ./initramfs/init

pushd ./initramfs
find . | cpio -o -H newc | gzip -c > ../initramfs.img
popd

\cp -f ./initramfs.img "${ROOTDIR}"/boot/
cd /tmp; rm -rf "${tempdir}"


mkdir -p "$ROOTDIR"/boot/zhiliao/
# touch "$ROOTDIR"/boot/zhiliao/rootfs-protect
install --mode=755 "${workdir}"/scripts/07-disk-protect/zhiliao-init "${ROOTDIR}"/etc/cron.d/
install --mode=755 "${workdir}"/scripts/07-disk-protect/zhiliao-init-script.sh "${ROOTDIR}"/root


grep -q initramfs /boot/config.txt
if [[  "$?" != "0" ]]; then
    echo "

dtoverlay=pi3-miniuart-bt
initramfs initramfs.img
" >> "$ROOTDIR"/boot/config.txt

fi

popd

