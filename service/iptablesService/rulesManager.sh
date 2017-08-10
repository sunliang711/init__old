#!/bin/bash
#对数据库进行操作的api

# sqlite3 "$db" "CREATE TABLE IF NOT EXISTS portConfig (type text,port int,enabled int,inputTraffic int,outputTraffic int,owner text,primary key(port,type));"
db=ROOT/db
list(){
    echo -e ".header on\n.mode column\nselect * from portConfig;" | sqlite3 "$db"
}

checkType(){
    if [ "$1" == "tcp" ] || [ "$1" == "udp" ];then
        return 0
    else
        echo "type is tcp or udp"
        return 1
    fi
}
checkPort(){
    if echo "$1" | grep -qP '^\d+$';then
        return 0
    else
        echo "port must decimal"
        return 1
    fi
}
addIptablesItem(){
    #protocol type
    type=$1
    port=$2

    if ! iptables -nL INPUT | grep $type | grep -q ":$port";then
        iptables -A INPUT -p $type --dport $port -j ACCEPT
    fi

    if ! iptables -nL OUTPUT | grep $type | grep -q ":$port";then
        iptables -A OUTPUT -p $type --sport $port
    fi
}

delIptablesItem(){
    type=$1
    port=$2
    number=$(iptables -nL INPUT --line-numbers | grep $type | grep ":$port"|awk '{print $1}')
    if [[ -n $number ]];then
        iptables -D INPUT $number
    fi
    number=$(iptables -nL OUTPUT --line-numbers | grep $type | grep ":$port"|awk '{print $1}')
    if [[ -n $number ]];then
        iptables -D OUTPUT $number
    fi

}

updateEnabled(){
    usage="Usage: update type port enabled"
    if (($#!=3));then
        echo "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    enabled=$3
    if ! echo $enabled | grep -qP '^[01]$';then
        echo "enabled must 0 or 1!"
        exit 1
    fi
    owner=$4
    exist=$(sqlite3 "$db" "select * from portConfig where type=\"$type\" and port=\"$port\";")
    #不存在则插入
    if [ -z "$exist" ];then
        sqlite3 "$db" "insert into portConfig(type,port,enabled,owner,inputTraffic,outputTraffic) values(\"$type\",$port,$enabled,\"$owner\",0,0);" || { echo "Add failed"; exit 1; }
    else
        #存在则更新
        sqlite3 "$db" "update portConfig set enabled=$enabled where type=\"$type\" and port=$port;"
    fi
}

enable(){
    usage="Usage: enable type port\n\t\tfor example:enable tcp 8388\n"
    if (($#!=2));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    owner=$3
    updateEnabled $type $port 1 $owner
    addIptablesItem $type $port
}

disable(){
    usage="Usage: disable type port [owner]\n\t\tfor example:disable tcp 8388\n"
    if (($#!=2));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    owner=$3
    updateEnabled $type $port 0 $owner
    delIptablesItem $type $port

}

clearInputTraffic(){
    usage="Usage: clearInputTraffic type port\n\t\tfor example clearInputTraffic udp 9091\n"
    if (($#!=2));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    sqlite3 "$db" "update portConfig set inputTraffic=0 where type=\"$type\" and port=$port;" || { echo "clearInputTraffic failed!"; exit 1; }
}

clearOutputTraffic(){
    usage="Usage: clearOutputTraffic type port\n\t\tfor example:clearOutputTraffic udp 90"
    if (($#!=2));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    sqlite3 "$db" "update portConfig set outputTraffic=0 where type=\"$type\" and port=$port;" || { echo "clearInputTraffic failed!"; exit 1; }
}

clearAll(){
    sqlite3 "$db" "update portConfig set outputTraffic=0,inputTraffic=0;"
}

getOutputTraffic(){
    usage="Usage: getOutputTraffic type port"
    if (($#!=2));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    sqlite3 "$db" "select outputTraffic from portConfig where type=\"$type\" and port=$port;"
}

usage(){
    echo "Usage: $(basename $0) list"
    echo -e "\t\t\tenable type port [owner](存在则enable,不存在则插入新的enable)"
    echo -e "\t\t\tdisable type port [onwer](存在则disable,不存在则插入新的disable)"
    echo -e "\t\t\tclearInput type port"
    echo -e "\t\t\tclearOutput type port"
    echo -e "\t\t\tgetOutputTraffic type port"
}
cmd=$1
shift
case "$cmd" in
    l|li|lis|list)
        list
        ;;
    en|ena|enab|enabl|enable)
        enable "$@"
        add "$@"
        #不能在这里重启iptables,因为在启动iptables的时候就会调用本脚本的enable或者add命令
        #enable或add之后又重启,这样就无限循环了
        # systemctl restart iptables
        ;;
    di|dis|disa|disab|disabl|disable)
        disable "$@"
        # systemctl restart iptables
        ;;
    clearI|clearInput)
        clearInputTraffic "$@"
        ;;
    clearO|clearOutput)
        clearOutputTraffic "$@"
        ;;
    clearAll)
        clearAll
        ;;
    getO|getOutputTraffic)
        getOutputTraffic "$@"
        ;;
    *)
        usage
        ;;
esac
