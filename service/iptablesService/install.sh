#!/bin/bash
if (( $EUID!=0 ));then
    echo "Need root privilege!"
    exit 1
fi

if ! command -v systemctl >/dev/null 2>&1;then
    echo "Iptables.service need systemctl cmd,but can not find it."
    exit 1
fi

#run on debian
if ! command -v sqlite3 >/dev/null 2>&1;then
    apt install -y sqlite3 || { echo "install sqlite3 failed!";exit 1; }
fi

#加入需要重装的话，当前的服务要先关掉
systemctl stop iptables.service >/dev/null 2>&1

serviceFileDir=/etc/systemd/system
root=/opt/iptables
db="$root/db"
rm -rf "$root" >/dev/null 2>&1
mkdir -p "$root"
mkdir -p "$root/plugin"
sqlite3 "$db" "CREATE TABLE IF NOT EXISTS portConfig (type text,port int,enabled int,inputTraffic int,outputTraffic int,plugin int,primary key(port,type));"
sqlite3 "$db" 'insert into portConfig values("tcp",22,1,0,0,0)' || { echo "Add tcp port 22 failed!";exit 1; }

startscript="$root/start-iptables"
stopscript="$root/stop-iptables"

sed  "s|ROOT|$root|" ./rulesManager.sh > /usr/local/bin/rulesManager.sh
chmod +x /usr/local/bin/rulesManager.sh

sed  "s|ROOT|$root|" ./start-iptables > "$root"/start-iptables
chmod +x "$root"/start-iptables

sed  "s|ROOT|$root|" ./stop-iptables > "$root"/stop-iptables
chmod +x "$root"/stop-iptables

sed -e "s|STARTSCRIPT|$startscript|" -e "s|STOPSCRIPT|$stopscript|" ./iptables.service > "$serviceFileDir/iptables.service"

systemctl daemon-reload
systemctl start iptables.service
systemctl enable iptables.service
