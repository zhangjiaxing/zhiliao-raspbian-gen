install --mode=755 ./scripts/09-fs-layout/init_resize.sh "${ROOTDIR}"/root

echo ' logo.nologo init=/root/init_resize.sh' >> "${ROOTDIR}"/boot/cmdline.txt
# sed -i 'N;s/\n//g' "${ROOTDIR}"/boot/cmdline.txt
sed -i ':label;N;s/\n//;b label' "${ROOTDIR}"/boot/cmdline.txt

install --mode=755 ./scripts/09-fs-layout/zhiliao-fs-layout "${ROOTDIR}"/etc/cron.d
install --mode=755 ./scripts/09-fs-layout/zhiliao-fs-layout-script.sh "${ROOTDIR}"/root

mkdir "${ROOTDIR}"/data

