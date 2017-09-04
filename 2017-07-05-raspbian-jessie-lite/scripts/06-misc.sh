
# skel
cp "${ROOTDIR}"/etc/skel/.[!.]*  "${ROOTDIR}"/root


# script-run-once
mkdir -p "${ROOTDIR}"/root/run-once
cp ./scripts/06-misc/script-run-once "${ROOTDIR}"/etc/cron.d/


# diable service
chroot "${ROOTDIR}" /bin/bash <<EOF

systemctl disable bluetooth.service
systemctl disable bluetooth.target
systemctl disable hciuart.service

systemctl disable console-setup.service
systemctl disable keyboard-setup.service

systemctl disable dhcpcd
systemctl disable raspi-config.service
EOF
