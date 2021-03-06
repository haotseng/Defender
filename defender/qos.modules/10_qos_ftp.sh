#!/bin/bash
########################################################################
# QoS: FTP 之流量控制設定
########################################################################
iptables -t mangle -A PREROUTING  -m layer7 --l7proto ftp -j MARK --set-mark 20
iptables -t mangle -A POSTROUTING -m layer7 --l7proto ftp -j MARK --set-mark 20
iptables -t mangle -A POSTROUTING -p tcp -s 192.168.7.3 --sport 2100:2200 -j MARK --set-mark 20
