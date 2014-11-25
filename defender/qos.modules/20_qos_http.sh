#!/bin/bash
########################################################################
# QoS: HTTP 之流量控制設定
########################################################################
#iptables -t mangle -A PREROUTING  -m layer7 --l7proto http -j MARK --set-mark 30
#iptables -t mangle -A POSTROUTING -m layer7 --l7proto http -j MARK --set-mark 30
iptables -t mangle -A POSTROUTING -p tcp -s 192.168.7.3 --sport 80 -j MARK --set-mark 30
