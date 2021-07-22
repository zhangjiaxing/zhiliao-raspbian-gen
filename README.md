# zhiliao-raspbian-gen 

## 对官方img镜像的改动

#### 默认设置
- 默认开启SSH，NTP，avahi-daemon。
- 默认开启蓝牙。
- 自动设置locale为zh_CN.UTF-8，设置键盘布局，时区，Wi-fi Country（影响信道支持）等。

#### 分区和文件系统
- 自动分区, 分区布局自适应sd卡大小, 支持16G 32G 和64G SD卡。
- 分区为 boot rootfs data 三个区。
- 实现了overlayfs作为根文件系统和ext4作为根文件系统两种开机方式，overlayfs方式开机能够延长SD卡rootfs分区寿命。
- initramfs 添加fsck e2label blkid 等多个工具，实现开机自动fsck  `data` `rootfs` 两个分区。

#### 默认安装软件
- 默认卸载openresolv。
- 默认安装eject tshark systemd-container docker.io network-manager。
- 默认使用network-manager管理网络。


#### rootfs说明
- overlayfs模式说明
> 类似openwrt，只会读取根文件系统，不会磁盘分区中写入数据。写入的数据实际保存在内存的tmpfs中。
> 特点：对系统分区只读不写入; rootfs的修改在关机后消失。

- 切换方式
> `nextboot-to-ro.sh命令下次开机使用overlayfs模式挂载rootfs`
> `nextboot-to-rw.sh下次开机使用ext4方式挂载rootfs`

--------

## 构建镜像前准备环境
```
cp 2017-07-05-raspbian-jessie-lite.zip      2017-07-05-raspbian-jessie-lite/image/
cp 2017-07-05-raspbian-jessie-lite.zip.sha1 2017-07-05-raspbian-jessie-lite/image/ 

bash ./2017-07-05-raspbian-jessie-lite/install-env.sh
```


## 构建镜像
```
cd ./2017-07-05-raspbian-jessie-lite/
sudo bash build.sh
```

