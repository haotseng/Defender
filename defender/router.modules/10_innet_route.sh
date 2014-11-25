#!/bin/bash
########################################################################
#  Route 192.168.7.0/24 via 192.168.9.2
########################################################################
#
# 新增一個routing table: iroute_1
#
grep -q '^199 ' /etc/iproute2/rt_tables 
if [ "$?" -ne 0 ]; then
    echo "199 iroute_1" >> /etc/iproute2/rt_tables
fi

#
# 清除此table 之所有資料
#
ip route flush table iroute_1
ip rule del table iroute_1

#
# 設定routing rule, Route 192.168.7.0/24 via 192.168.9.2
#
ip route add table iroute_1 192.168.7.0/24 via 192.168.9.2 dev eth0

# <<Hao>> It seems a bug of linux kernel before 2.6.20.
# Refer: http://grokbase.com/t/centos.org/centos/2009/03/centos-port-based-routing/09ankvnrqf7moo66c5ydh2vtkzwq
# Refer: http://mailman.ds9a.nl/pipermail/lartc/2007q1/020493.html
# I can't use 'all' argument for ip rule setting.
# I did the trick with replacing 'all' with '0.0.0.0/0'

#ip rule add from 0.0.0.0/0 table iroute_1
ip rule add from all table iroute_1


########################################################################
# flush cache
########################################################################
ip route flush cache

