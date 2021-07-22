#!/bin/bash

# timezone

timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true
systemctl enable ntp

sleep 1

