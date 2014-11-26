#!/bin/bash
########################################################################
# 允許特定service進入(本機的service)
########################################################################

#------------------------------------
# NTP sever 設定 (使用port 123, UDP)
#------------------------------------
 iptables -t filter -A INPUT -p udp --dport 123 -j ACCEPT  
 
#-------------------------------------------------------------
# FTP service (port 20,21, port for passive mode 21000-21100)
#-------------------------------------------------------------
# iptables -t filter -A INPUT -p tcp --dport 21  -j ACCEPT     
# iptables -t filter -A INPUT -p tcp --dport 20  -j ACCEPT    
# iptables -t filter -A INPUT -p tcp --dport 21000:21100  -j ACCEPT 

