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

#portConfig表的plugin字段表示是否是plugin，如果是plug的话，启动service的时候先把plugin为1的记录删除，然后把eanbled为1
#的端口加入到规则中，然后执行plugin文件夹下所有的脚本，在这些脚本里面调用addPluginPort来增加端口，然后启用这些端口
addPluginPort(){
    usage="Usage: addPluginPort type port\n\t\tfor example:addPluginPort tcp 8388\n"
    if (($#!=2));then
        echo -e "$usage"
        exit 1
    fi
    type=$1
    checkType $type || exit 1
    port=$2
    checkPort $port || exit 1
    #1先搜索是否有该记录(根据type和port),如果有,则将enabled置1,没有才删除
    exist=$(sqlite3 "$db" "select * from portConfig where type=\"$type\" and port=\"$port\";")
    if [ -z "$exist" ];then
        sqlite3 "$db" "insert into portConfig values(\"$type\",$port,1,0,0,1);" || { echo "Add failed"; exit 1; }
    else
        sqlite3 "$db" "update portConfig set enabled=1 where type=\"$type\" and port=\"$port\";"
    fi
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
    sqlite3 "$db" "update portConfig set enabled=$enabled where type=\"$type\" and port=$port;" || { echo "UpdateEnabled failed!"; exit 1; }
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
    echo -e "\t\t\taddPluginPort type port"
    echo -e "\t\t\tdelete type port"
    echo -e "\t\t\tenable type port"
    echo -e "\t\t\tdisable type port"
    echo -e "\t\t\tclearInput type port"
    echo -e "\t\t\tclearOutput type port"
}

case $1 in
    l|li|lis|list)
        list
        ;;
    a|ad|add)
        add $2 $3
        systemctl restart iptables
        ;;
    addPluginPort)
        addPluginPort $2 $3
        ;;
    de|del|dele|delete)
        del $2 $3
        systemctl restart iptables
        ;;
    en|ena|enab|enabl|enable)
        enable $2 $3
        systemctl restart iptables
        ;;
    di|dis|disa|disab|disabl|disable)
        disable $2 $3
        systemctl restart iptables
        ;;
    clearI|clearInput)
        clearInputTraffic $2 $3
        ;;
    clearO|clearOutput)
        clearOutputTraffic $2 $3
        ;;
    clearAll)
        clearAll
        ;;
    getO|getOutputTraffic)
        getOutputTraffic $2 $3
        ;;
    *)
        usage
        ;;
esac
