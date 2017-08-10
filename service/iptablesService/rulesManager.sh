#!/bin/bash
#对数据库进行操作的api

# sqlite3 "$db" "CREATE TABLE IF NOT EXISTS portConfig (type text,port int,enabled int,inputTraffic int,outputTraffic int,plugin int,primary key(port,type));"
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
add(){
    usage="Usage: add type port\n\t\tfor example:add tcp 8388\n"
    if (($#!=2));then
        echo -e "$usage"
        exit 1
    fi

    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    sqlite3 "$db" "insert into portConfig values(\"$type\",$port,1,0,0,0);" || { echo "Add failed"; exit 1; }
}

del(){
    usage="Usage: del type port\n\t\tfor example: del tcp 8388\n"
    if (($#!=2));then
        echo "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    sqlite3 "$db" "delete from portConfig where type=\"$type\" and port=$port;" || { echo "Del failed!"; exit 1; }
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
    exist=$(sqlite3 "$db" "select * from portConfig where type=\"$type\" and port=\"$port\";")
    #不存在则插入
    if [ -z "$exist" ];then
        sqlite3 "$db" "insert into portConfig values(\"$type\",$port,$enabled,0,0,1);" || { echo "Add failed"; exit 1; }
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
    updateEnabled $type $port 1
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
    updateEnabled $type $port 0

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
    echo -e "\t\t\tadd type port"
    echo -e "\t\t\tdelete type port"
    echo -e "\t\t\tenable type port(存在则enable,不存在则插入新的enable)"
    echo -e "\t\t\tdisable type port"
    echo -e "\t\t\tclearInput type port"
    echo -e "\t\t\tclearOutput type port"
}
cmd=$1
shift
case "$cmd" in
    l|li|lis|list)
        list
        ;;
    a|ad|add)
        # add "$@"
        enable "$@"
        #不能在这里重启iptables,因为在启动iptables的时候就会调用本脚本的enable或者add命令
        #enable或add之后又重启,这样就无限循环了
        # systemctl restart iptables
        ;;
    de|del|dele|delete)
        del "$@"
        # systemctl restart iptables
        ;;
    en|ena|enab|enabl|enable)
        enable "$@"
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
