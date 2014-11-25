#!/bin/bash
########################################################################
# 處理PPPoE 在Forward時, MSS 可能太大的問題
########################################################################
  if [ "$EXTIF" != "" ]; then
     for extif in $EXTIF 
     do 
        pppintf=`echo $extif | sed 's/ppp[0-9]/ppp/g'`
        ## 若對外的介面是ppp0 ~ ppp9 的話, 將強制修改TCP 中的MSS值
        if [ "$pppintf" == "ppp" ]; then
            iptables -t mangle -o $extif --insert FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1400:65495 -j TCPMSS --clamp-mss-to-pmtu
        fi
     done
  fi

