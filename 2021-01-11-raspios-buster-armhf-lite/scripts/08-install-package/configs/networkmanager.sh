
# sed -i s/managed=false/managed=true/g /etc/NetworkManager/NetworkManager.conf

cat <<eof >/etc/NetworkManager/NetworkManager.conf 
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true

[keyfile]
unmanaged-devices=interface-name:wlan0
eof

systemctl enable network-manager

