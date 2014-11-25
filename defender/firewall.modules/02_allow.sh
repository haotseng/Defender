#!/bin/bash
########################################################################
# 允許特定internet 的 IP 進入
########################################################################
  if [ "$INIF" != "" ]; then
    for inif in $INIF
    do
      iptables -t filter -A INPUT -i $inif -j ACCEPT     #讓對內的網路介面可以進入
    done
  fi

# 允許內部的網域進入
  if [ "$INNET" != "" ]; then
    for innet in $INNET
    do
      iptables -t filter -A INPUT -s $innet -j ACCEPT     # 允許特定網段進入
    done
  fi

#  iptables -t filter -A INPUT -s 140.117.11.12   -j ACCEPT     # 允許特定IP進入
#  iptables -t filter -A INPUT -s 192.168.7.0/24  -j ACCEPT     # 允許特定網段進入
#  iptables -t filter -A INPUT -s 10.7.0.0/24     -j ACCEPT     # 允許特定網段進入
#  iptables -t filter -A INPUT -s 192.168.7.0/24  -j ACCEPT     # 允許特定網段進入
  iptables -t filter -A INPUT -s 192.168.9.0/24  -j ACCEPT     # 允許特定網段進入
