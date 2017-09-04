
mount -t tmpfs -o size=512M tmpfs "${ROOTDIR}"/var/cache/apt

# mount --bind ./scripts/08-install-package/apt-source/sources.list "${ROOTDIR}"/etc/apt/sources.list
# mount --bind ./scripts/08-install-package/apt-source/raspi.list   "${ROOTDIR}"/etc/apt/sources.list.d/raspi.list

mv "${ROOTDIR}"/etc/apt/sources.list "${ROOTDIR}"/etc/apt/sources.list.bak
mv "${ROOTDIR}"/etc/apt/sources.list.d/raspi.list "${ROOTDIR}"/etc/apt/sources.list.d/raspi.list.bak
cat ./scripts/08-install-package/apt-source/sources.list >| "${ROOTDIR}"/etc/apt/sources.list


chroot "${ROOTDIR}" /bin/bash <<EOF
#download package
apt-get clean
apt-get -y update
apt-get -dy install vim tmux
apt-get -dy install network-manager curl
apt-get -dy install git

# install packages
cd /var/cache/apt/archives/
dpkg -i *.deb

apt-get clean
EOF

chroot "${ROOTDIR}" /bin/bash <./scripts/08-install-package/networkmanager.sh


# umount "${ROOTDIR}"/etc/apt/sources.list
# umount "${ROOTDIR}"/etc/apt/sources.list.d/raspi.list
umount "${ROOTDIR}"/var/cache/apt

