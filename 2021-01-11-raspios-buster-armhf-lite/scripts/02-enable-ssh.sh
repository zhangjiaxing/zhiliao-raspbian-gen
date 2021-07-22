#!/bin/bash

# ln -s /lib/systemd/system/ssh.service "${ROOTDIR}"/etc/systemd/system/multi-user.target.wants/ssh.service
chroot "${ROOTDIR}" /bin/bash <<<"systemctl enable ssh"

