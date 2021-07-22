

mount -t tmpfs -o size=512M tmpfs "${ROOTDIR}"/var/cache/apt

# mount --bind ./scripts/08-install-package/apt-source/sources.list "${ROOTDIR}"/etc/apt/sources.list
# mount --bind ./scripts/08-install-package/apt-source/raspi.list   "${ROOTDIR}"/etc/apt/sources.list.d/raspi.list

mv "${ROOTDIR}"/etc/apt/sources.list "${ROOTDIR}"/etc/apt/sources.list.bak
mv "${ROOTDIR}"/etc/apt/sources.list.d/raspi.list "${ROOTDIR}"/etc/apt/sources.list.d/raspi.list.bak

cp -f ./scripts/08-install-package/apt-source/sources.list "${ROOTDIR}"/etc/apt/sources.list
cp -f ./scripts/08-install-package/apt-source/raspi.list   "${ROOTDIR}"/etc/apt/sources.list.d/raspi.list


chroot "${ROOTDIR}" /bin/bash <<EOF
# 安装的包
debs0="xfsprogs apt-file initramfs-tools busybox-static"
debs1="ppp pppoe pptp-linux  network-manager"
debs2="python3 docker.io "
debs3="vim tmux jq htop "
debs4="avahi-utils avahi-daemon nbtscan eject"
debs5="dnsmasq rsync git haveged systemd-container tshark"
debs6="dnsutils hping3 iputils-arping traceroute tcpdump curl"
debs="\${debs0} \${debs1} \${debs2} \${debs3} \${debs4} \${debs5} \${debs6}"


#download package
apt-get clean
apt-get -y purge openresolv
# 安装软件时，禁用dialog对话框
export DEBIAN_FRONTEND=noninteractive

# 开始安装
apt-get -yq update
apt-get -yq update

for deb in \$debs;do
    echo   "正在安装\${deb}..."
    while true ;do
        apt-get -yqq install \${deb} > /dev/null 2>&1
        is_install=\$(check_deb \$deb)

        if [[ ! "\${is_install}" ]];then
            is_install=\$(check_deb \$deb)
            echo "\${deb}正在尝试重新安装..."
            sleep 5
        else
            okinfo "\${deb}安装成功"
            break
        fi
    done

done

#for i in 1 2 ; do
#    apt-get -yqq install ppp pppoe pptp-linux  network-manager
#    apt-get -yqq install nodejs npm python3 busybox-static libldns-dev libjson-c-dev libpcap-dev
#    apt-get -yqq install vim tmux sshpass jq htop proxychains
#    apt-get -yqq install avahi-utils avahi-daemon eject
#    apt-get -yqq install openvpn hostapd dnsmasq rsync git haveged systemd-container tshark
#    apt-get -yqq install dnsutils nmap hping3 iputils-arping traceroute tcpdump iperf3 mtr-tiny curl
#    # apt-get -y install apt-file
#done

sync
apt-get clean

systemctl enable haveged
# systemctl stop haveged
EOF


#umount "${ROOTDIR}"/etc/apt/sources.list
#umount "${ROOTDIR}"/etc/apt/sources.list.d/raspi.list
umount "${ROOTDIR}"/var/cache/apt


chroot "${ROOTDIR}" /bin/bash < ./scripts/08-install-package/configs/networkmanager.sh
# cp ./scripts/08-install-package/init/init-network.sh "${ROOTDIR}"/root/run-once
\cp -f ./scripts/08-install-package/configs/*con "${ROOTDIR}"/etc/NetworkManager/system-connections
chmod 0600 "${ROOTDIR}"/etc/NetworkManager/system-connections/*

