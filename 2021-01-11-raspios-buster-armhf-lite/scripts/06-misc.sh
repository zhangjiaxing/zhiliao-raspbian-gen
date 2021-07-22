
# skel
cp "${ROOTDIR}"/etc/skel/.[!.]*  "${ROOTDIR}"/root
cp ./scripts/06-misc/vimrc "${ROOTDIR}"/root/.vimrc

# script-run-once
mkdir -p "${ROOTDIR}"/root/run-once
install --mode=755 ./scripts/06-misc/script-run-once "${ROOTDIR}"/etc/cron.d/

# timedate
install --mode=755 ./scripts/06-misc/timedate.sh "${ROOTDIR}"/root/run-once

# system verison
VER=$(basename $IMG | awk -F '-' '{print $1"-"$2"-"$3}')
echo "xlxd-linux $VER ($BUILD_TIME)" >| "${ROOTDIR}"/etc/version.txt

#watchdog
echo -e "\nRuntimeWatchdogSec=10\nShutdownWatchdogSec=2min" >> "${ROOTDIR}"/etc/systemd/system.conf

# diable service
chroot "${ROOTDIR}" /bin/bash <<EOF

# systemctl disable bluetooth.service
# systemctl disable bluetooth.target
# systemctl disable hciuart.service

systemctl disable console-setup.service
systemctl disable keyboard-setup.service

systemctl disable dhcpcd
systemctl disable raspi-config.service
EOF
