HOSTNAME="zhiliao-debian"

echo "$HOSTNAME" > "${ROOTDIR}"/etc/hostname

chroot "${ROOTDIR}" /bin/bash <<EOF
chpasswd <<<root:jiaxing
userdel -r pi 2> /dev/null

# ssh root login
# sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
EOF

# hosts
echo -e "127.0.1.1 \t ${HOSTNAME}" >> "${ROOTDIR}"/etc/hosts
sed -i /^.*raspberrypi.*/d  "${ROOTDIR}"/etc/hosts

