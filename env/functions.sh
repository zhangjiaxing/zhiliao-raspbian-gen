#!/bin/bash

function checksha1(){
    sum=$(sha1sum $1)
    sumtxt=$(cat "${1}.sha1")
    if [ "$sum" != "${sumtxt}" ];then
        echo "SHA-1 don't match"
    else
        echo "ok"
    fi
}

function mountimg(){
# $1 : image file
    loopdev=`losetup --show -Pf "$1"`
    sleep 3
    mount "${loopdev}p2" /mnt
    mount "${loopdev}p1" /mnt/boot
}


function umountimg(){
    umount /mnt/boot
    umount /mnt
    losetup -D
    losetup
}

