#!/bin/bash
########################################################################
# 禁止特定internet 的 IP 進入
########################################################################
#  iptables -t mangle -A PREROUTING -s 64.105.47.242   -j DROP       # 阻擋特定IP
#  iptables -t mangle -A PREROUTING -s 124.42.113.58   -j DROP       # 阻擋特定IP
#  iptables -t mangle -A PREROUTING -s 218.57.128.242  -j DROP       # 阻擋特定IP
#  iptables -t mangle -A PREROUTING -s 114.44.0.0/16   -j DROP       # 阻擋特定網段
#  iptables -t mangle -A PREROUTING -s 192.168.0.0/23   -j DROP       # 阻擋特定網段
#  iptables -t mangle -A PREROUTING -s 123.204.0.0/16  -p tcp --dport 25 -j DROP  #阻擋特定網段使用smtp
# 
########################################################################
# 禁止特定internet 的 IP forward 
########################################################################
#  iptables -t mangle -A FORWARD -s 192.168.1.0/24   -j DROP       # 阻擋特定網段 forward
#  iptables -t mangle -A FORWARD -s 192.168.0.0/255.255.255.63   -j DROP       # 阻擋特定IP forward
