HOSTNAME="zhiliao-debian"

echo "$HOSTNAME" > "${ROOTDIR}"/etc/hostname

chroot "${ROOTDIR}" /bin/bash <<EOF
chpasswd <<<'root:123456'
userdel -r pi

# ssh root login
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
EOF

# hosts
echo -e "127.0.1.1 \t ${HOSTNAME}" >> /etc/hosts
