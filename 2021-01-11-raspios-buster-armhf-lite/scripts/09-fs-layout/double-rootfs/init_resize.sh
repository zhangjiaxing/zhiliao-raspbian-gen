#!/bin/sh

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

reboot_pi () {
  umount /boot
  mount / -o remount,ro
  sync
  echo b > /proc/sysrq-trigger
  sleep 5
  exit 0
}

get_variables () {
  ROOT_PART_DEV=$(findmnt / -o source -n)
  ROOT_PART_NAME=$(echo "$ROOT_PART_DEV" | cut -d "/" -f 3)
  ROOT_DEV_NAME=$(echo /sys/block/*/"${ROOT_PART_NAME}" | cut -d "/" -f 4)
  ROOT_DEV="/dev/${ROOT_DEV_NAME}"
  ROOT_PART_NUM=$(cat "/sys/block/${ROOT_DEV_NAME}/${ROOT_PART_NAME}/partition")

  BOOT_PART_DEV=$(findmnt /boot -o source -n)
  BOOT_PART_NAME=$(echo "$BOOT_PART_DEV" | cut -d "/" -f 3)
  BOOT_DEV_NAME=$(echo /sys/block/*/"${BOOT_PART_NAME}" | cut -d "/" -f 4)
  BOOT_PART_NUM=$(cat "/sys/block/${BOOT_DEV_NAME}/${BOOT_PART_NAME}/partition")

  ROOT_DEV_SIZE=$(cat "/sys/block/${ROOT_DEV_NAME}/size")
  TARGET_END=$((ROOT_DEV_SIZE - 1))

  PARTITION_TABLE=$(parted -m "$ROOT_DEV" unit s print | tr -d 's')

  LAST_PART_NUM=$(echo "$PARTITION_TABLE" | tail -n 1 | cut -d ":" -f 1)

  ROOT_PART_LINE=$(echo "$PARTITION_TABLE" | grep -e "^${ROOT_PART_NUM}:")
  ROOT_PART_START=$(echo "$ROOT_PART_LINE" | cut -d ":" -f 2)
  ROOT_PART_END=$(echo "$ROOT_PART_LINE" | cut -d ":" -f 3)
}


main () {
  get_variables

if expr "$ROOT_DEV_SIZE" ">=" "122167296"; then
    #64G sd card
sfdisk -f --no-reread "$ROOT_DEV" <<EOF
unit: sectors

/dev/sda1 : start=        8192, size=      524288, type=c
/dev/sda2 : start=      532480, size=     6291456, type=83
/dev/sda3 : start=     6823936, size=     6291456, type=83
/dev/sda4 : start=    13115392, size=   109051904, type=83
EOF

elif expr "$ROOT_DEV_SIZE" ">=" "58814463"; then
    # 32G /dev/sda4   (start + size - 1) == 58814463

sfdisk -f --no-reread "$ROOT_DEV" <<EOF
unit: sectors

/dev/sda1 : start=        8192, size=      524288, type=c
/dev/sda2 : start=      532480, size=     6291456, type=83
/dev/sda3 : start=     6823936, size=     6291456, type=83
/dev/sda4 : start=    13115392, size=    45699072, type=83
EOF

else
  # 16G sd card

sfdisk -f --no-reread "$ROOT_DEV" <<EOF
unit: sectors

/dev/sda1 : start=        8192, size=      524288, type=c
/dev/sda2 : start=      532480, size=     6291456, type=83
/dev/sda3 : start=     6823936, size=     6291456, type=83
/dev/sda4 : start=    13115392, size=    16338944, type=83
EOF

fi

  partprobe "$ROOT_DEV"

  return 0
}

mount -t devtmpfs devtmpfs /dev
mount -t proc proc /proc
mount -t sysfs sys /sys

mount -t vfat -o rw LABEL=boot /boot
mount -o remount,rw /

sed -i 's| init=/root/init_resize.sh||' /boot/cmdline.txt
sync

echo 1 > /proc/sys/kernel/sysrq

main
sleep 10

whiptail --infobox "Resized filesystem. Rebooting in 10 seconds..." 20 60
sleep 10

reboot_pi
