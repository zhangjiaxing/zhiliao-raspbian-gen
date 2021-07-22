#!/bin/bash


# check EUID
if [[ "$EUID" != "0" ]]; then
    echo "Please run this as root"
    exit
fi

apt update -y
apt install busybox-static initramfs-tools jq udisks2 -y

