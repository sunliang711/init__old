#!/bin/bash
#add this file to cron job
nginxConf="/etc/nginx/nginx.conf"
if [ ! -e "$nginxConf" ];then
    echo "$nginxConf does not exist,error!"
    exit 1
fi
logfile=$(grep access_log "$nginxConf"|grep -oP '/.+(?=;)')
echo "logfile: $logfile"
pidfile=$(grep '^pid' "$nginxConf" | grep -oP '/.+(?=;)')
echo "pidfile: $pidfile"
pid=$(cat $pidfile)
echo "pid: $pid"

# slientExe(){
#     eval "$*" >/dev/null 2>&1
# }

# slientExe rm -f "${logfile}.7"
# slientExe mv "${logfile}.6" "${logfile}.7"
# slientExe mv "${logfile}.5" "${logfile}.6"
# slientExe mv "${logfile}.4" "${logfile}.5"
# slientExe mv "${logfile}.3" "${logfile}.4"
# slientExe mv "${logfile}.2" "${logfile}.3"
# slientExe mv "${logfile}.1" "${logfile}.2"
# slientExe mv "${logfile}" "${logfile}.1"


#rotate backup
bk(){
    if (($# < 1));then
        echo "Usage: bk the_existing_file_or_directory [optional_max_number]"
        return 1
    fi
    local file="$1"
    local maxNo="${2:-7}"
    if [ ! -e "$file" ];then
        echo "$file" does not exist!
        return 2
    fi
    if ! echo "$maxNo" | grep '^[0-9]\+$' >/dev/null 2>&1;then
        echo "optional_max_number must be number!"
        return 3
    fi
    if (($maxNo<1));then
        echo "optional_max_number must >= 1"
        return 4
    fi

    rm -vf "${file}.${maxNo}" 2>/dev/null
    ((maxNo--))
    for i in $(seq "$maxNo" -1 1);do
        ((j=i+1))
        mv -v "${file}.${i}" "${file}.${j}" 2>/dev/null
    done
    mv -v "${file}" "${file}.1"
}

slientExe(){
    eval "$@" >/dev/null 2>&1
}

bk "$logfile"
kill -USR1 "$pid"
