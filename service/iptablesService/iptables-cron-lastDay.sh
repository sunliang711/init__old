#!/bin/bash
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin


#restart iptables service
systemctl restart iptables

#save all traffic of this month
month=$(date +%Y/%m)
traffic=$(rulesManager list)
echo "$month" >>ROOT/traffic-month
echo "$traffic" >>ROOT/traffic-month


#clear all traffic
rulesManager.sh clearAll

