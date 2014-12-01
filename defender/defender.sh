#!/bin/bash
########################################################################
# Functions
########################################################################
function check_ipv4 () {
    if [ `echo $1 | grep -E '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'  | grep -o "\." | wc -l` -eq 3 ];
    then 
      ipv4=true;
    else 
      ipv4=false;
    fi
}

function reset_iptables () {
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
}

function load_modules () {
  ########################################################################
  # 啟用Defender相關模組
  ########################################################################
    ########################################################################
    # 載入QoS 模組
    ########################################################################
    case "$ENABLE_SRV_QOS" in
      [yY]|[yY][eE][sS])
        eval echo                                 ${out_fd}
        eval echo "\| Starting Qos Modules..."     ${out_fd}
        eval echo "----------------------------"  ${out_fd}
        qos_files=`ls ${QOS_MOD_PATH} | sort`
        for run_module in $qos_files 
        do 
           eval echo "Load QoS module : ${run_module}" ${out_fd}
           ${QOS_MOD_PATH}/${run_module}
        done
        eval echo "Qos Setting Done."  ${out_fd}
      ;;
    esac

    ########################################################################
    # 載入Firewall 模組
    ########################################################################
    case "$ENABLE_SRV_FIREWALL" in
      [yY]|[yY][eE][sS])
        eval echo                                   ${out_fd}
        eval echo "\| Starting Firewall Modules..."  ${out_fd}
        eval echo "------------------------------"  ${out_fd}
        firewall_modules=`ls ${FIREWALL_MOD_PATH} | sort`
        for run_module in $firewall_modules 
        do 
           eval echo "Load firewall module : ${run_module}"  ${out_fd}
           ${FIREWALL_MOD_PATH}/${run_module}
        done
        eval echo "Firewall Setting Done."  ${out_fd}
      ;;
    esac

    ########################################################################
    # 載入 routing table 設定
    ########################################################################
    case "$ENABLE_SRV_ROUTER" in
      [yY]|[yY][eE][sS])
        eval echo                                 ${out_fd}
        eval echo "\| Starting Router Modules..."  ${out_fd}
        eval echo "----------------------------"  ${out_fd}
        router_modules=`ls ${ROUTER_MOD_PATH} | sort`
        for run_module in $router_modules 
        do 
           eval echo "Load router module : ${run_module}"  ${out_fd}
           ${ROUTER_MOD_PATH}/${run_module}
        done
        eval echo "Router Setting Done."  ${out_fd}
      ;;
    esac

    ########################################################################
    # 載入使用者自訂模組
    ########################################################################
    if [ "$USER_MOD_PATH" != "" ]; then

      eval echo                                 ${out_fd}
      eval echo "\| Starting User Modules..."   ${out_fd}
      eval echo "----------------------------"  ${out_fd}
      user_modules=`ls ${USER_MOD_PATH} | sort`
      for run_module in $user_modules
      do
         eval echo "Load User module : ${run_module}"  ${out_fd}
         ${USER_MOD_PATH}/${run_module}
      done
      eval echo "User Modules Setting Done."  ${out_fd}

    fi
}

########################################################################
# Bash start here
########################################################################
  this_script=`echo $0 | sed "s/^.*\///"`
  script_path=`echo $0 | sed "s/\/${this_script}$//"`

case "$2" in
  daemon)
     out_fd=" >/dev/null"         # run as daemon mode, all message output to /dev/null
     ;;
  debug)                    
     out_fd=" >>/root/defender/dbg.log"  # run as debug mode, log all message in file "dbg.log"
     ;;
  *)
     out_fd=" >&1"                # run as normal mode, all message output to std-out
     ;;
esac

case "$1" in
  start)
   ENABLE_DEFENDER=1
   eval echo "---------------------" ${out_fd}
   eval echo "\| Starting Defender \|" ${out_fd}
   eval echo "---------------------" ${out_fd}
   ;;
  stop)
   ENABLE_DEFENDER=0
   eval echo "---------------------" ${out_fd}
   eval echo "\| Stopping Defender \|" ${out_fd}
   eval echo "---------------------" ${out_fd}
   ;;
  *)
   eval echo "Usage: $this_script {start|stop} [daemon]" >&2
   exit 1
   ;;
esac

########################################################################
#  載入並且檢查設定檔 
########################################################################
  if [ -f $script_path/defender.conf ]; then
    . $script_path/defender.conf
  else
    eval echo "Can't find $script_path/defender.conf file!!" >&2
    exit 1
  fi

  case "$IS_REALIP_FIXED" in
    [yY]|[yY][eE][sS])
      ALWAYS_DETECT_REALIP=0
      ;;
    [nN]|[nN][oO])
      ALWAYS_DETECT_REALIP=1
      ;;
    *)
      eval echo "\"IS_REALIP_FIXED\" missed in config " >&2
      exit 1
      ;;
  esac

  if [ "$REALIP" == "AUTO" ]; then
    sleep 10                                                # 等待$EXTIF 介面穩定(ex: ppp0)
    REALIP=`${script_path}/get_intf_ip.sh ${EXTIF}`         # 自動偵測真實IP
  else
    if [ "$ALWAYS_DETECT_REALIP" == "1" ]; then
        eval echo "\"IS_REALIP_FIXED\" settings in config file is wrong" >&2
        exit 1
    fi
  fi

  eval echo "REAL IP="$REALIP ${out_fd}

  check_ipv4 $REALIP      # call check_ipv4()
  if [ "$ipv4" != "true" ]; then
    eval echo "$REALIP isn't a IPV4 format" >&2
    exit 1
  fi

########################################################################
#  環境變數及目錄設定 
########################################################################
  PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin; 
  export PATH

  FIREWALL_MOD_PATH=$script_path/firewall.d            # firewall 模組的路徑
  QOS_MOD_PATH=$script_path/qos.d                      # QoS 模組的路徑
  ROUTER_MOD_PATH=$script_path/router.d                # Router 模組的路徑
  USER_MOD_PATH=""                                     # 使用者自訂模組路徑
  if [ "$USER_MODULE_DIR" != "" ]; then
    if [ -d $script_path/$USER_MODULE_DIR ]; then
      USER_MOD_PATH=$script_path/$USER_MODULE_DIR
    else
      echo "Can't find dir $script_path/$USER_MODULE_DIR" >&2
      exit 1
    fi
  fi

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
  #for i in /proc/sys/net/ipv4/conf/*/rp_filter; do
  #  echo "1" > $i
  #done
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
# 啟用IP Forward (讓本機可以當做Router)
########################################################################
  echo "1" > /proc/sys/net/ipv4/ip_forward


########################################################################
# Main Loop
########################################################################
  
  reset_iptables    # call reset_iptables()


  if [ "$ENABLE_DEFENDER" == "1" ]; then

    export EXTIF INIF AINIF INNET REALIP
    load_modules  # call load_modules()
 
    while [ "$ALWAYS_DETECT_REALIP" == "1" ]
    do
      sleep 60     # 每分鐘偵測一次IP

      eval echo "Detecting the realip.." ${out_fd}
      new_ip=`${script_path}/get_intf_ip.sh ${EXTIF}`         # 自動偵測真實IP

      if [ "$new_ip" != "$REALIP" ]; then                     # 檢查IP是否有變化?
        check_ipv4 $new_ip                                    # call check_ipv4(), 檢查IPv4格式
        if [ "$ipv4" == "true" ]; then
          # 重新載入所有Defender module
          eval echo "The realip changed, new IP=$new_ip" ${out_fd}
          REALIP=$new_ip

          reset_iptables    # call reset_iptable()
          export EXTIF INIF AINIF INNET REALIP
          load_modules      # call load_modules()
        fi
      fi
    done

  fi

########################################################################
# End
########################################################################
  eval echo "--------" ${out_fd}
  eval echo "\| Done \|" ${out_fd}
  eval echo "--------" ${out_fd}

