#!/bin/bash
########################################################################
# 啟用 IP 分享功能
########################################################################
  if [ "$INNET" != "" ]; then
    for innet in $INNET
    do
      iptables -t nat -A POSTROUTING -s $innet -o $EXTIF -j MASQUERADE
    done
  fi

