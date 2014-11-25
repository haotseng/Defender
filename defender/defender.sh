#!/bin/bash
#
  this_script=`echo $0 | sed "s/^.*\///"`
  script_path=`echo $0 | sed "s/\/${this_script}$//"`

case "$1" in
  start)
   ENABLE_DEFENDER=1
   echo "---------------------"
   echo "| Starting Defender |"
   echo "---------------------"
   ;;
  stop)
   ENABLE_DEFENDER=0
   echo "---------------------"
   echo "| Stopping Defender |"
   echo "---------------------"
   ;;
  *)
   echo "Usage: $this_script {start|stop}" >&2
   exit 1
   ;;
esac

########################################################################
#  載入設定檔 
########################################################################
  if [ -f $script_path/defender.conf ]; then
    . $script_path/defender.conf
  else
    echo "Can't find $script_path/defender.conf file!!"
    exit 1
  fi

  if [ "$REALIP" == "AUTO" ]; then
    REALIP=`${script_path}/get_intf_ip.sh ${EXTIF}`         # 自動偵測真實IP
  fi

  echo "REAL IP="$REALIP
  export EXTIF INIF AINIF INNET REALIP


########################################################################
#  環境變數及目錄設定 
########################################################################
  PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin; 
  export PATH

  FIREWALL_MOD_PATH=$script_path/firewall.d            # firewall 模組的路徑
  QOS_MOD_PATH=$script_path/qos.d                      # QoS 模組的路徑
  ROUTER_MOD_PATH=$script_path/router.d                # Router 模組的路徑

########################################################################
#  個人化設定啊！請自行填寫您自己想要預先啟動的一些基礎資料。
########################################################################
  allowname=''			# 允許登入本機的 hostname ，必須是 Internet 找的到的 hostname。
  allowip=""
  if [ "$allowname" != "" ]; then
    for siteiptmp in `echo $allowname`
    do
          siteip=`/usr/bin/host $siteiptmp 168.95.1.1    | grep address|tail -n 1 | awk '{print $4}'`
          testip=`echo $siteip | grep [^0-9.]`
          if [ "$testip" == "" ]; then
               allowip="$allowip  $siteip"
          fi
    done
  fi
  export allowip

########################################################################
# 設定好核心的網路功能：
########################################################################
  # 開啟 TCP Flooding 的 DoS 攻擊抵擋機制，但這個設定不適合 loading 已經很高的主機！！！
  echo "1" > /proc/sys/net/ipv4/tcp_syncookies

  # 取消 ping 廣播的回應；
  echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

  # 開啟逆向路徑過濾，以符合 IP 封包與網路介面的設定；
  # 
#  for i in /proc/sys/net/ipv4/conf/*/rp_filter; do
#	echo "1" > $i
#  done
  for i in /proc/sys/net/ipv4/conf/*/rp_filter; do
	echo "0" > $i
  done

  # 開啟記錄有問題的封包
  # record some problems packets.
  for i in /proc/sys/net/ipv4/conf/*/log_martians; do
	echo "1" > $i
  done

  # 取消來源路由，這個設定值是可以取消的；
  for i in /proc/sys/net/ipv4/conf/*/accept_source_route; do
	echo "0" > $i
  done

  # 取消重新宣告路徑的功能。
  for i in /proc/sys/net/ipv4/conf/*/accept_redirects; do
	echo "0" > $i
  done

  # 取消傳送重新宣告路徑的功能。
  for i in /proc/sys/net/ipv4/conf/*/send_redirects; do
	echo "0" > $i
  done

########################################################################
# 載入一些有用的核心模組
########################################################################
  modules="ip_tables iptable_mangle iptable_nat ip_nat ip_nat_ftp ip_nat_irc ip_conntrack ip_conntrack_ftp ip_conntrack_irc xt_mark"
  for mod in $modules
  do
	testmod=`lsmod | grep "^${mod} " | awk '{print $1}'`
	if [ "$testmod" == "" ]; then
		modprobe $mod
	fi
  done

########################################################################
# 清除規則、設定預設政策及開放 lo 與相關的設定值
########################################################################
  # 清除所有規則
  iptables -F -t filter
  iptables -X -t filter
  iptables -Z -t filter
  iptables -F -t mangle
  iptables -X -t mangle
  iptables -Z -t mangle
  iptables -F -t nat
  iptables -X -t nat
  iptables -Z -t nat

  # 設定預設策略
  iptables -t filter -P INPUT       DROP
  iptables -t filter -P OUTPUT      ACCEPT
  iptables -t filter -P FORWARD     ACCEPT
  iptables -t mangle -P INPUT       ACCEPT
  iptables -t mangle -P OUTPUT      ACCEPT
  iptables -t mangle -P FORWARD     ACCEPT
  iptables -t mangle -P PREROUTING  ACCEPT
  iptables -t mangle -P POSTROUTING ACCEPT
  iptables -t nat    -P PREROUTING  ACCEPT
  iptables -t nat    -P OUTPUT      ACCEPT
  iptables -t nat    -P POSTROUTING ACCEPT

  iptables -t filter -A INPUT -i lo -j ACCEPT
  iptables -t filter -A INPUT -m state --state RELATED -j ACCEPT
  iptables -t filter -A INPUT -m state --state ESTABLISHED -j ACCEPT

########################################################################
# 啟用IP Forward (讓本機可以當做Router)
########################################################################
  echo "1" > /proc/sys/net/ipv4/ip_forward

########################################################################
# 啟用Defender相關模組
########################################################################
  if [ "$ENABLE_DEFENDER" == "1" ]; then

    ########################################################################
    # 載入QoS 模組
    ########################################################################
    case "$ENABLE_SRV_QOS" in
      [yY]|[yY][eE][sS])
        echo 
        echo "| Starting Qos Modules..."
        echo "----------------------------"      
        qos_files=`ls ${QOS_MOD_PATH} | sort`
        for run_module in $qos_files 
        do 
           echo "Load QoS module : ${run_module}"
           ${QOS_MOD_PATH}/${run_module}
        done
        echo "Qos Setting Done."
      ;;
    esac

    ########################################################################
    # 載入Firewall 模組
    ########################################################################
    case "$ENABLE_SRV_FIREWALL" in
      [yY]|[yY][eE][sS])
        echo 
        echo "| Starting Firewall Modules..."
        echo "------------------------------"
        firewall_modules=`ls ${FIREWALL_MOD_PATH} | sort`
        for run_module in $firewall_modules 
        do 
           echo "Load firewall module : ${run_module}"
           ${FIREWALL_MOD_PATH}/${run_module}
        done
        echo "Firewall Setting Done."
      ;;
    esac

    ########################################################################
    # 載入 routing table 設定
    ########################################################################
    case "$ENABLE_SRV_ROUTER" in
      [yY]|[yY][eE][sS])
        echo 
        echo "| Starting Router Modules..."
        echo "----------------------------"
        router_modules=`ls ${ROUTER_MOD_PATH} | sort`
        for run_module in $router_modules 
        do 
           echo "Load router module : ${run_module}"
           ${ROUTER_MOD_PATH}/${run_module}
        done
        echo "Router Setting Done."
      ;;
    esac

  fi  # if "$ENABLE_DEFENDER" == "1" 

########################################################################
# End
########################################################################
  echo "--------"
  echo "| Done |"
  echo "--------"
