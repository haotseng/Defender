#!/bin/bash
enable_this_module=0

if [ $enable_this_module != "1" ]; then
    exit 0;
fi

########################################################################
# 設定 routing table for tun0
########################################################################

# 新增一個routing table: vpn
grep -q '^200 ' /etc/iproute2/rt_tables 
if [ "$?" -ne 0 ]; then
    echo "200 vpn" >> /etc/iproute2/rt_tables
fi

# 清除此table 之所有資料
ip route flush table vpn
ip rule del table vpn

# 設定routing rule
ip route show table main | grep -Ev ^default | while read ROUTE ; do ip route add table vpn $ROUTE; done
#ip route add table company default via 192.168.0.1 dev eth0  proto static
#ip route add table company default via 192.168.0.1 dev eth0 
ip route add table vpn default dev tun0

#
#
# <<Hao>> It seems a bug of linux kernel before 2.6.20.
# Refer: http://grokbase.com/t/centos.org/centos/2009/03/centos-port-based-routing/09ankvnrqf7moo66c5ydh2vtkzwq
# Refer: http://mailman.ds9a.nl/pipermail/lartc/2007q1/020493.html
# I can't use 'all' argument for ip rule setting.
# I did the trick with replacing 'all' with '0.0.0.0/0'

#ip rule add from all fwmark 1 table vpn
ip rule add from 0.0.0.0/0 fwmark 1 table vpn

########################################################################
# 設定 routing table for tun1
########################################################################

# 新增一個routing table: vpn_2
grep -q '^210 ' /etc/iproute2/rt_tables 
if [ "$?" -ne 0 ]; then
    echo "210 vpn_2" >> /etc/iproute2/rt_tables
fi

# 清除此table 之所有資料
ip route flush table vpn_2
ip rule del table vpn_2

# 設定routing rule
ip route show table main | grep -Ev ^default | while read ROUTE ; do ip route add table vpn $ROUTE; done
#ip route add table company default via 192.168.0.1 dev eth0  proto static
#ip route add table company default via 192.168.0.1 dev eth0 
ip route add table vpn_2 default dev tun1

#
#
# <<Hao>> It seems a bug of linux kernel before 2.6.20.
# Refer: http://grokbase.com/t/centos.org/centos/2009/03/centos-port-based-routing/09ankvnrqf7moo66c5ydh2vtkzwq
# Refer: http://mailman.ds9a.nl/pipermail/lartc/2007q1/020493.html
# I can't use 'all' argument for ip rule setting.
# I did the trick with replacing 'all' with '0.0.0.0/0'

#ip rule add from all fwmark 2 table vpn_2
ip rule add from 0.0.0.0/0 fwmark 2 table vpn_2



ip route flush cache
