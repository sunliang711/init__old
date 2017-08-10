#!/bin/bash

#mail traffic to my email
#TODO
if [ ! -e /etc/shellrc ];then
    echo "Missing shellrc"
    exit 1
fi
source /etc/shellrc

traffic=$(traffic)
portConfig=$(rulesManager.sh list)
content="$traffic $portConfig"
mailto sunliang711@163.com "vultr traffic statistics" "$content"
