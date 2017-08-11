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
#delete $root except plugin/ folder
if [ -d "$root" ];then
    cd "$root"
    find . -maxdepth 1 ! -name . -a ! -name plugin | xargs -d '\n' rm -rf
    cd -
else
    mkdir -p "$root"/plugin
fi
cp  plugin/* "$root"/plugin

sqlite3 "$db" "CREATE TABLE IF NOT EXISTS portConfig (type text,port int,enabled int,inputTraffic int,outputTraffic int,owner text,primary key(port,type));"

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

sed -e "s|ROOT|$root|" ./iptables-cron-lastDay.sh >"$root"/iptables-cron-lastDay.sh
chmod +x "$root"/iptables-cron-lastDay.sh

sed -e "s|ROOT|$root|" ./iptables-cron-everyDay.sh >"$root"/iptables-cron-everyDay.sh
chmod +x "$root"/iptables-cron-everyDay.sh

systemctl daemon-reload
read -p "Start iptables.service? [y/n] " s
if [[ $s == y* ]];then
    systemctl start iptables.service
fi
read -p "Auto start iptables.service when boot? [y/n] " s
if [[ $s == y* ]];then
    systemctl enable iptables.service
fi

read -p "Install cron job [y/n] " s
if [[ $s == y* ]];then
    #set cron job
    job=$root/iptables-cron-lastDay.sh
    #delete it ,if existes
    crontab -l 2>/dev/null | grep -v "$job" | crontab -
    #add job
    (crontab -l 2>/dev/null;echo "59 23 28-31 * * [ \$(date -d +1day +\\%d) -eq 1 ] && $job")|crontab -

    job=$root/iptables-cron-everyDay.sh
    #delete it ,if existes
    crontab -l 2>/dev/null | grep -v "$job" | crontab -
    #add job
    (crontab -l 2>/dev/null;echo "0 17 * * * $job")|crontab -
fi
