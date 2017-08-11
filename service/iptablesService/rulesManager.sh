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
    checkType $type || exit 1
    checkPort $port || exit 1

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
    checkType $type || exit 1
    checkPort $port || exit 1
    number=$(iptables -nL INPUT --line-numbers | grep $type | grep ":$port"|awk '{print $1}')
    if [[ -n $number ]];then
        iptables -D INPUT $number
    fi
    number=$(iptables -nL OUTPUT --line-numbers | grep $type | grep ":$port"|awk '{print $1}')
    if [[ -n $number ]];then
        iptables -D OUTPUT $number
    fi

}

add(){
    # sqlite3 "$db" "CREATE TABLE IF NOT EXISTS portConfig (type text,port int,enabled int,inputTraffic int,outputTraffic int,owner text,primary key(port,type));"
    usage="Usage: add type port [owner]\n\t\tfor example:add tcp 8388 [eagle]"
    if (($#<2));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    port=$2
    owner=${3:-nobody}
    checkType $type || exit 1
    checkPort $port || exit 1
    exist=$(sqlite3 "$db" "select * from portConfig where type=\"$type\" and port=$port;")
    if [[ -n "$exist" ]];then
        echo "Alread exist record for type:$type port:$port"
    else
        sqlite3 "$db" "insert into portConfig(type,port,enabled,owner,inputTraffic,outputTraffic) values(\"$type\",$port,1,\"$owner\",0,0);"
        addIptablesItem $type $port
    fi
}

del(){
    usage="Usage: del type port\n\t\tfor example: del tcp 8388"
    if (( $#!=2 ));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    port=$2
    checkType $type || exit 1
    checkPort $port || exit 1
    exist=$(sqlite3 "$db" "select * from portConfig where type=\"$type\" and port=$port;")
    if [[ -n "$exist" ]];then
        sqlite3 "$db" "delete from portConfig where type=\"$type\" and port=$port;"
        delIptablesItem $type $port
    else
        echo "Doesn't exist record for type:$type port:$port"
    fi
}

enable(){
    usage="Usage: enable type port \n\t\tfor example:enable tcp 8388 \n"
    if (($#!=2));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    exist=$(sqlite3 "$db" "select * from portConfig where type=\"$type\" and port=$port;")
    if [[ -n "$exist" ]];then
        #存在则更新
        sqlite3 "$db" "update portConfig set enabled=1 where type=\"$type\" and port=$port;"
        addIptablesItem $type $port
    else
        echo "Doesn't exist record for type:$type port:$port"
    fi
}

disable(){
    usage="Usage: disable type port\n\t\tfor example:disable tcp 8388\n"
    if (($#!=2));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    exist=$(sqlite3 "$db" "select * from portConfig where type=\"$type\" and port=$port;")
    if [[ -n "$exist" ]];then
        #存在则更新
        sqlite3 "$db" "update portConfig set enabled=0 where type=\"$type\" and port=$port;"
        delIptablesItem $type $port
    else
        echo "Doesn't exist record for type:$type port:$port"
    fi

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
    sqlite3 "$db" "select type,port,outputTraffic from portConfig where type=\"$type\" and port=$port;"
}

usage(){
    echo "Usage: $(basename $0) list"
    echo -e "\t\t\tadd type port [owner]"
    echo -e "\t\t\tdel type port"
    echo -e "\t\t\tenable type port"
    echo -e "\t\t\tdisable type port"
    echo -e "\t\t\tclearInput type port"
    echo -e "\t\t\tclearOutput type port"
    echo -e "\t\t\tclearAll"
    echo -e "\t\t\tgetOutputTraffic type port"
}
cmd=$1
shift
case "$cmd" in
    l|li|lis|list)
        list
        ;;
    add)
        add "$@"
        ;;
    del)
        del "$@"
        ;;
    en|ena|enab|enabl|enable)
        enable "$@"
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
