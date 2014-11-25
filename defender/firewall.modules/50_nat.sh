#!/bin/bash
########################################################################
# 啟用 IP 分享功能
########################################################################
  if [ "$INNET" != "" ]; then
    for innet in $INNET
    do
#      iptables -t nat -A POSTROUTING -s $innet -o $EXTIF -j MASQUERADE
      iptables -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
#      iptables -t nat -A POSTROUTING -s $innet -j MASQUERADE
    done
  fi


#   iptables -t nat -A POSTROUTING -s 192.168.9.0/24 -o $EXTIF -j MASQUERADE
#   iptables -t nat -A POSTROUTING -o $EXTIF -j SNAT --to-source $REALIP
#   iptables -t nat -A PREROUTING -i $EXTIF -j DNAT --to-destination 192.168.9.254
  
   
   #iptables -t nat -A POSTROUTING -s 192.168.9.0/24 -o tun1 -j MASQUERADE
   
   #iptables -t nat -A POSTROUTING -s 192.168.9.0/24 -o $EXTIF -j MASQUERADE
   #iptables -t nat -A POSTROUTING -s 192.168.9.0/24 -j MASQUERADE
