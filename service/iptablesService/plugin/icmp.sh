#!/bin/bash
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
iptables -t filter -A INPUT -p icmp -j ACCEPT
