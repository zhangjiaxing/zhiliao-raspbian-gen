workdir=`pwd`

# swapoff
chroot "${ROOTDIR}" /bin/bash<<EOF
systemctl stop dphys-swapfile 2>&1 | grep -v systemd-sysv-install
systemctl disable dphys-swapfile 2>&1 | grep -v systemd-sysv-install
dphys-swapfile uninstall 2>&1 | grep -v "swapoff failed"
EOF

install --mode=755 ./scripts/07-disk-protect/sbin/nextboot-to-ro.sh  "${ROOTDIR}"/usr/local/sbin/
install --mode=755 ./scripts/07-disk-protect/sbin/nextboot-to-rw.sh  "${ROOTDIR}"/usr/local/sbin/


# overlayfs
tempdir=`mktemp -d --suffix=.mkinitramfs`
pushd "${tempdir}"

mkdir -p ./initramfs/{bin,sbin,etc,dev,lib,proc,sys}
cp /bin/busybox ./initramfs/bin/
/bin/busybox --install -s ./initramfs/bin


# fstab and mtab
touch "${tempdir}/initramfs/etc/fstab"
ln -s /proc/mounts "${tempdir}/initramfs/etc/mtab"


# mkdir -p initramfs/lib/modules/`uname -r`
# cp "${ROOTDIR}"/lib/modules/`uname -r`/modules.{builtin,order} initramfs/lib/modules/`uname -r`
# mkdir -p initramfs/lib/modules/`uname -r`/kernel/fs/overlayfs
# cp -a "${ROOTDIR}"/lib/modules/`uname -r`/kernel/fs/overlayfs/overlay.ko initramfs/lib/modules/`uname -r`/kernel/fs/overlayfs
# depmod -a --basedir initramfs

for MOD_PATH in "${ROOTDIR}"/lib/modules/*; do
    kernel_version=$(echo "${MOD_PATH}" | cut -d "/" -f 6)
    mkdir -p ./initramfs/lib/modules/"$kernel_version"
    cp "${ROOTDIR}"/lib/modules/"$kernel_version"/modules.{builtin,order} ./initramfs/lib/modules/"$kernel_version"/
    install -D "${ROOTDIR}"/lib/modules/"$kernel_version"/kernel/fs/overlayfs/overlay.ko ./initramfs/lib/modules/"$kernel_version"/kernel/fs/overlayfs/overlay.ko
    install -D "${ROOTDIR}"/lib/modules/"$kernel_version"/kernel/fs/squashfs/squashfs.ko ./initramfs/lib/modules/"$kernel_version"/kernel/fs/squashfs/squashfs.ko
    install -D "${ROOTDIR}"/lib/modules/"$kernel_version"/kernel/fs/isofs/isofs.ko       ./initramfs/lib/modules/"$kernel_version"/kernel/fs/isofs/isofs.ko
    install -D "${ROOTDIR}"/lib/modules/"$kernel_version"/kernel/fs/ntfs/ntfs.ko         ./initramfs/lib/modules/"$kernel_version"/kernel/fs/ntfs/ntfs.ko
    install -D "${ROOTDIR}"/lib/modules/"$kernel_version"/kernel/fs/xfs/xfs.ko           ./initramfs/lib/modules/"$kernel_version"/kernel/fs/xfs/xfs.ko

    depmod -a --basedir ./initramfs "$kernel_version"
done


install --mode=755 "${workdir}"/scripts/07-disk-protect/init ./initramfs/init

# install fsck, blkid, e2label
(
    source "${ROOTDIR}"/usr/share/initramfs-tools/scripts/functions
    source "${ROOTDIR}"/usr/share/initramfs-tools/hook-functions
    export DESTDIR="${tempdir}"/initramfs
    export DPKG_ARCH=`dpkg --print-architecture`
    export verbose="n"

    # workaround: libgcc always needed on old-abi arm
    if [ "$DPKG_ARCH" = arm ] || [ "$DPKG_ARCH" = armeb ]; then
        cp -a /lib/libgcc_s.so.1 "${DESTDIR}/lib/"
    fi

    copy_exec /sbin/fsck /sbin
    copy_exec /sbin/e2fsck /sbin
    copy_exec /sbin/blkid /sbin
    copy_exec /sbin/e2label /sbin
    copy_exec /sbin/xfs_repair /sbin

    mkdir -p "${DESTDIR}/etc"
    cat >"${DESTDIR}/etc/e2fsck.conf" <<EOF
[options]
broken_system_clock=1
EOF

    for type in ext2 ext3 ext4 fat msdos vfat xfs; do
        prog="/sbin/fsck.${type}"
        
        if [ -h "$prog" ]; then
                link=$(readlink -f "$prog")
                copy_exec "$link"
                ln -s "/usr/$link" "${DESTDIR}/usr/$prog"
        elif [ -x "$prog" ] ; then
                copy_exec "$prog"
        else
                echo "Warning: /sbin/fsck.${type} doesn't exist, can't install to initramfs, ignoring."
        fi
    done

	# make sure that library search path is up to date
	cp -ar /etc/ld.so.conf* "$DESTDIR"/etc/
	if ! ldconfig -r "$DESTDIR" ; then
    	[ $(id -u) != "0" ] && echo "ldconfig might need uid=0 (root) for chroot()" >&2
	fi
	
	# dirty hack for armhf s double-linker situation; if we have one of
	# the two known eglibc linkers, nuke both and re-create sanity
	if [ "$DPKG_ARCH" = armhf ]; then
        rm -f "${DESTDIR}"/lib/arm-linux-gnueabihf/ld-linux.so.*
        rm -f "${DESTDIR}"/lib/ld-linux-armhf.so.*
        cp -aL /lib/ld-linux-armhf.so.* "${DESTDIR}/lib/"
        mkdir -p "${DESTDIR}/lib/arm-linux-gnueabihf/"
        ld_so=$(basename /lib/ld-linux-armhf.so.*)
        ln -sf /lib/ld-linux-armhf.so.* "${DESTDIR}/lib/arm-linux-gnueabihf/${ld_so}"
	fi
)


pushd ./initramfs
find . | cpio -o -H newc | gzip -c > ../initramfs.img
popd

\rm -f "${ROOTDIR}"/boot/initramfs.img
\cp -f ./initramfs.img "${ROOTDIR}"/boot/
popd; 

rm -rf "${tempdir}"


mkdir -p "$ROOTDIR"/boot/xlxd/
# touch "$ROOTDIR"/boot/xlxd/rootfs-protect
install --mode=755 "${workdir}"/scripts/07-disk-protect/xlxd-init "${ROOTDIR}"/etc/cron.d/
install --mode=755 "${workdir}"/scripts/07-disk-protect/xlxd-init-script.sh "${ROOTDIR}"/root


grep -q initramfs "$ROOTDIR"/boot/config.txt
if [[  "$?" != "0" ]]; then
    echo "

enable_uart=1
core_freq=250
initramfs initramfs.img
" >> "$ROOTDIR"/boot/config.txt

fi

