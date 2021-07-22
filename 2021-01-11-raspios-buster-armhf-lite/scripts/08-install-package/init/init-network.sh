#!/bin/bash

IFNAME=eth0

DEFAULT_STATIC_IP='192.168.1.200/24'
DEFAULT_STATIC_GW=192.168.1.1

DEFAULT_PPPOE_USERNAME='username@pppoe'
DEFAULT_PPPOE_PASSWORD=123456


# add dhcp connection
nmcli connection add autoconnect yes save yes ifname "${IFNAME}" con-name dhcp-con type ethernet

## add static connection
#nmcli connection add autoconnect no save yes ifname "${IFNAME}" con-name static-con type ethernet ip4 "${DEFAULT_STATIC_IP}" gw4 "${DEFAULT_STATIC_GW}"

## add pppoe connection
#nmcli connection add autoconnect no save yes ifname '*' con-name pppoe-con type pppoe username "${DEFAULT_PPPOE_USERNAME}" password "${DEFAULT_PPPOE_PASSWORD}"

