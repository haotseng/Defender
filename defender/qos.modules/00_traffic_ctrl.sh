#!/bin/bash
#
# Coyote local command init script

#
#Note: 這裡用的單位bps 是指Byte per second.
#

#
# QoS 上傳方面 ($EXTIF 為網路輸出介面, 即"eth0"或"eth1")

if [ "$EXTIF" != "" ]; then 
   echo "Set Traffic Control for $EXTIF"
   # 清除 $EXTIF 所有佇列規則
   tc qdisc del dev $EXTIF root 2>/dev/null

   # 定義最頂層(根)佇列規則，並指定 default 類別編號 (預設編號為70)
   tc qdisc add dev $EXTIF root handle 10: htb default 70 

   # 定義第一層的 10:1 類別 (總頻寬)  (上傳總頻寬 768kbps = 96kBps)
   tc class add dev $EXTIF parent 10:  classid 10:1 htb rate 96kbps ceil 96kbps 

   # 定義第二層葉類別
   # rate 保證頻寬，ceil 最大頻寬，prio 優先權
   tc class add dev $EXTIF parent 10:1 classid 10:10 htb rate 2kbps   ceil 4kbps   prio 2
   tc class add dev $EXTIF parent 10:1 classid 10:20 htb rate 12kbps  ceil 24kbps  prio 3
   tc class add dev $EXTIF parent 10:1 classid 10:30 htb rate 12kbps  ceil 24kbps  prio 3
   tc class add dev $EXTIF parent 10:1 classid 10:40 htb rate 2kbps   ceil 16kbps  prio 0
   tc class add dev $EXTIF parent 10:1 classid 10:50 htb rate 2kbps   ceil 12kbps  prio 1
   tc class add dev $EXTIF parent 10:1 classid 10:60 htb rate 2kbps   ceil 96kbps  prio 1
   # 這個為預設值
   tc class add dev $EXTIF parent 10:1 classid 10:70 htb rate 10kbps  ceil 96kbps  prio 1

   # 定義各葉類別的佇列規則
   # parent 類別編號，handle 葉類別佇列規則編號
   # 由於採用 fw 過濾器，所以此處使用 pfifo 的佇列規則即可
   tc qdisc add dev $EXTIF parent 10:10 handle 101: pfifo
   tc qdisc add dev $EXTIF parent 10:20 handle 102: pfifo
   tc qdisc add dev $EXTIF parent 10:30 handle 103: pfifo
   tc qdisc add dev $EXTIF parent 10:40 handle 104: pfifo
   tc qdisc add dev $EXTIF parent 10:50 handle 105: pfifo
   tc qdisc add dev $EXTIF parent 10:60 handle 106: pfifo
   tc qdisc add dev $EXTIF parent 10:70 handle 107: pfifo

   # 設定過濾器
   # 指定貼有 10 標籤 (handle) 的封包，歸類到 10:10 類別，以此類推
   tc filter add dev $EXTIF parent 10: protocol ip prio 100 handle 10 fw classid 10:10
   tc filter add dev $EXTIF parent 10: protocol ip prio 100 handle 20 fw classid 10:20
   tc filter add dev $EXTIF parent 10: protocol ip prio 100 handle 30 fw classid 10:30
   tc filter add dev $EXTIF parent 10: protocol ip prio 100 handle 40 fw classid 10:40
   tc filter add dev $EXTIF parent 10: protocol ip prio 100 handle 50 fw classid 10:50
   tc filter add dev $EXTIF parent 10: protocol ip prio 100 handle 60 fw classid 10:60
   tc filter add dev $EXTIF parent 10: protocol ip prio 100 handle 70 fw classid 10:70
fi


# QoS 下載方面 ($INIF 為網路輸出介面, 即"eth0"或"eth1")
#

if [ "$INIF" != "" ]; then
   echo "Set Traffic Control for $INIF"
   # 清除 $INIF 所有佇列規則
   tc qdisc del dev $INIF root 2>/dev/null

   # 定義最頂層(根)佇列規則，並指定 default 類別編號
   tc qdisc add dev $INIF root handle 10: htb default 70
   # 定義第一層的 10:1 類別 (總頻寬) (下載總頻寬3Mbps = 384KBps)
   tc class add dev $INIF parent 10:  classid 10:1 htb rate 384kbps ceil 384kbps 

   # 定義第二層葉類別
   # rate 保證頻寬，ceil 最大頻寬，prio 優先權
   tc class add dev $INIF parent 10:1 classid 10:10 htb rate 2kbps ceil 32kbps prio 2
   tc class add dev $INIF parent 10:1 classid 10:20 htb rate 48kbps ceil 96kbps prio 3
   tc class add dev $INIF parent 10:1 classid 10:30 htb rate 48kbps ceil 96kbps prio 3
   tc class add dev $INIF parent 10:1 classid 10:40 htb rate 16kbps ceil 196kbps prio 0 
   tc class add dev $INIF parent 10:1 classid 10:50 htb rate 8kbps ceil 188kbps prio 1
   tc class add dev $INIF parent 10:1 classid 10:60 htb rate 8kbps ceil 188kbps prio 1
   # 這個為預設值
   tc class add dev $INIF parent 10:1 classid 10:70 htb rate 8kbps ceil 384kbps prio 1

   # 定義各葉類別的佇列規則
   # parent 類別編號，handle 葉類別佇列規則編號
   tc qdisc add dev $INIF parent 10:10 handle 101: pfifo
   tc qdisc add dev $INIF parent 10:20 handle 102: pfifo
   tc qdisc add dev $INIF parent 10:30 handle 103: pfifo
   tc qdisc add dev $INIF parent 10:40 handle 104: pfifo
   tc qdisc add dev $INIF parent 10:50 handle 105: pfifo
   tc qdisc add dev $INIF parent 10:60 handle 106: pfifo
   tc qdisc add dev $INIF parent 10:70 handle 107: pfifo

   # 設定過濾器
   tc filter add dev $INIF parent 10: protocol ip prio 100 handle 10 fw  classid 10:10
   tc filter add dev $INIF parent 10: protocol ip prio 100 handle 20 fw  classid 10:20
   tc filter add dev $INIF parent 10: protocol ip prio 100 handle 30 fw  classid 10:30
   tc filter add dev $INIF parent 10: protocol ip prio 100 handle 40 fw  classid 10:40
   tc filter add dev $INIF parent 10: protocol ip prio 100 handle 50 fw  classid 10:50
   tc filter add dev $INIF parent 10: protocol ip prio 100 handle 60 fw  classid 10:60
   tc filter add dev $INIF parent 10: protocol ip prio 100 handle 70 fw  classid 10:70
fi
