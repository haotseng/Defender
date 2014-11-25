#!/bin/bash
enable_this_module=0

if [ $enable_this_module != "1" ]; then
    exit 0;
fi

########################################################################
# 設定route table flag
########################################################################
  # port 80(http) using routing table 'vpn'
#  iptables -A PREROUTING -t mangle -i eth1 -p tcp --dport 80 -j MARK --set-mark 1
#  iptables -A PREROUTING -t mangle -i eth1 -p udp --dport 80 -j MARK --set-mark 1

  # port 443(https) using routing table 'vpn'
#  iptables -A PREROUTING -t mangle -i eth1 -p tcp --dport 443 -j MARK --set-mark 1
#  iptables -A PREROUTING -t mangle -i eth1 -p udp --dport 443 -j MARK --set-mark 1

  # port 143(imap) using routing table 'vpn'
#  iptables -A PREROUTING -t mangle -i eth1 -p tcp --dport 143 -j MARK --set-mark 1
#  iptables -A PREROUTING -t mangle -i eth1 -p udp --dport 143 -j MARK --set-mark 1

  # port 20/21(ftp) using routing table 'vpn'
#  iptables -A PREROUTING -t mangle -i eth1 -p tcp --dport 20 -j MARK --set-mark 1
#  iptables -A PREROUTING -t mangle -i eth1 -p udp --dport 20 -j MARK --set-mark 1
#  iptables -A PREROUTING -t mangle -i eth1 -p tcp --dport 21 -j MARK --set-mark 1
#  iptables -A PREROUTING -t mangle -i eth1 -p udp --dport 21 -j MARK --set-mark 1


## Create iptables rules for packet marking (for VPN 1)
iptables -t mangle -N MFIP
### Only mark packets bound for the Internet
iptables -t mangle -A MFIP --dst 192.168.0.0/23 --jump RETURN
iptables -t mangle -A MFIP --dst 172.16.0.0/12 --jump RETURN
iptables -t mangle -A MFIP --dst 169.254.0.0/16 --jump RETURN
iptables -t mangle -A MFIP --jump MARK --set-mark 1

## Create iptables rules for packet marking (for VPN 2)
iptables -t mangle -N MFIP2
### Only mark packets bound for the Internet
iptables -t mangle -A MFIP2 --dst 192.168.0.0/23 --jump RETURN
iptables -t mangle -A MFIP2 --dst 172.16.0.0/12 --jump RETURN
iptables -t mangle -A MFIP2 --dst 169.254.0.0/16 --jump RETURN
iptables -t mangle -A MFIP2 --jump MARK --set-mark 2

##iptables -t mangle -A POSTROUTING -p tcp -m multiport ! --dports 80,443,53 --jump MFIP
#iptables -t mangle -A PREROUTING -i ${AINIF} -p tcp -m multiport ! --dports 80,443,53 --jump MFIP
##iptables -t mangle -A PREROUTING -i ${AINIF} -p tcp -m multiport ! --dports 443,53 --jump MFIP

##iptables -t mangle -A PREROUTING -i ${AINIF} -s 192.168.9.50 --jump MFIP2
##iptables -t mangle -A PREROUTING -i ${AINIF} -s 192.168.9.51 --jump MFIP2
