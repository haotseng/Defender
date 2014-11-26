#!/bin/bash
########################################################################
# 啟用 IP 分享功能
########################################################################
  if [ "$INNET" != "" ]; then
    for innet in $INNET
    do

      #
      # 正常NAT 使用方式
      #
      iptables -t nat -A POSTROUTING -s $innet -o $EXTIF -j MASQUERADE

      #
      # 下面是為了當有service(例如www) 在 NAT 後面時, 若內部的另一台電腦
      # 要連線此service時, 需要使用下列方式, 才能正常連線
      #
      iptables -t nat -A POSTROUTING -s $innet -d $innet -j MASQUERADE

    done
  fi

