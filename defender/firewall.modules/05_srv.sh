#!/bin/bash
########################################################################
# 允許特定service進入(本機的service)
########################################################################
  # FTP service
#  iptables -t filter -A INPUT -p tcp --dport 21  -j ACCEPT     
#  iptables -t filter -A INPUT -p tcp --dport 20  -j ACCEPT    
#  iptables -t filter -A INPUT -p tcp --dport 21000:21100  -j ACCEPT 
