#!/bin/bash
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

#save all traffic of this month to db
#TODO


#clear all traffic
rulesManager.sh clearAll

#restart iptables service
systemctl restart iptables
