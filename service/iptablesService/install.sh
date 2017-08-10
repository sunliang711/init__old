#!/bin/bash
if (( $EUID!=0 ));then
    echo "Need root privilege!"
    exit 1
fi
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPTDIR"

if ! command -v systemctl >/dev/null 2>&1;then
    echo "Iptables.service need systemctl cmd,but can not find it."
    exit 1
fi

#run on debian
if ! command -v sqlite3 >/dev/null 2>&1;then
    apt install -y sqlite3 || { echo "install sqlite3 failed!";exit 1; }
fi

#假如需要重装的话，当前的服务要先关掉
systemctl stop iptables.service >/dev/null 2>&1

serviceFileDir=/etc/systemd/system
root=/opt/iptables
db="$root/db"
rm -rf "$root" >/dev/null 2>&1
mkdir -p "$root"
cp -r plugin "$root"
sqlite3 "$db" "CREATE TABLE IF NOT EXISTS portConfig (type text,port int,enabled int,inputTraffic int,outputTraffic int,plugin int,primary key(port,type));"

startscript="$root/start-iptables"
stopscript="$root/stop-iptables"

sed  "s|ROOT|$root|" ./rulesManager.sh > "$root"/rulesManager.sh
chmod +x "$root"/rulesManager.sh
ln -sf "$root"/rulesManager.sh /usr/local/bin

sed  "s|ROOT|$root|" ./start-iptables > "$root"/start-iptables
chmod +x "$root"/start-iptables

sed  "s|ROOT|$root|" ./stop-iptables > "$root"/stop-iptables
chmod +x "$root"/stop-iptables

sed -e "s|STARTSCRIPT|$startscript|" -e "s|STOPSCRIPT|$stopscript|" ./iptables.service > "$serviceFileDir/iptables.service"

systemctl daemon-reload
systemctl start iptables.service
systemctl enable iptables.service
