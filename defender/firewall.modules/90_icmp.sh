#!/bin/bash
########################################################################
# 允許某些類型的 ICMP 封包進入 (給ping指令用)
########################################################################
  if [ "$EXTIF" != "" ]; then
     AICMP="0 3 3/4 4 11 12 14 16 18"
     for tyicmp in $AICMP 
     do 
	iptables -t filter -A INPUT -i $EXTIF -p icmp --icmp-type $tyicmp -j ACCEPT
     done
  fi

