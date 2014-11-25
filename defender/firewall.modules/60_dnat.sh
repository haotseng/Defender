#!/bin/bash
########################################################################
# NAT 主機後端的 LAN 內對外之伺服器設定 
########################################################################

if [ "$REALIP" != "" ]; then
  echo ".. setup DNAT"
  #------------------
  # WWW (port 80)
  #------------------
#  iptables -t nat -A PREROUTING -p tcp -d $REALIP --dport 80 -j DNAT --to 192.168.9.110:80 

  #------------------
  # RSYNC (port 873)
  #------------------
#  iptables -t nat -A PREROUTING -p tcp -d $REALIP --dport 873 -j DNAT --to 192.168.7.244:873 
#  iptables -t nat -A PREROUTING -p udp -d $REALIP --dport 873 -j DNAT --to 192.168.7.244:873 

  #------------------
  # FTP (cmd port: 21,  passive mode data port 2100:2200)
  #------------------
#  iptables -t nat -A PREROUTING -p tcp -d $REALIP --dport 2100:2200 -j DNAT --to 192.168.7.3:2100-2200 
#  iptables -t nat -A PREROUTING -p tcp -d $REALIP --dport 21 -j DNAT --to 192.168.7.3:21

  #------------------
  # for BT (port 40824)
  #------------------
#  iptables -t nat -A PREROUTING -p tcp -d $REALIP --dport 40824 -j DNAT --to 192.168.7.13:40824
#  iptables -t nat -A PREROUTING -p udp -d $REALIP --dport 40824 -j DNAT --to 192.168.7.13:40824

  #------------------
  # for DNS (port 53)
  #------------------
#  iptables -t nat -A PREROUTING -p tcp -d $REALIP --dport 53 -j DNAT --to 192.168.7.7:53
#  iptables -t nat -A PREROUTING -p udp -d $REALIP --dport 53 -j DNAT --to 192.168.7.7:53

  #------------------
  # for SAMBA (port 135-139,445,42,43)
  #------------------
#  iptables -t nat -A PREROUTING -p tcp -d $REALIP --dport 135:139 -j DNAT --to 192.168.9.13:135-139
#  iptables -t nat -A PREROUTING -p udp -d $REALIP --dport 135:139 -j DNAT --to 192.168.9.13:135-139
#  iptables -t nat -A PREROUTING -p tcp -d $REALIP --dport 42:43   -j DNAT --to 192.168.9.13:42-43
#  iptables -t nat -A PREROUTING -p udp -d $REALIP --dport 42:43   -j DNAT --to 192.168.9.13:42-43
#  iptables -t nat -A PREROUTING -p tcp -d $REALIP --dport 445     -j DNAT --to 192.168.9.13:445
#  iptables -t nat -A PREROUTING -p udp -d $REALIP --dport 445     -j DNAT --to 192.168.9.13:445

fi
