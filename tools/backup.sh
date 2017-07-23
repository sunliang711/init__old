#!/bin/bash

logpath=/root/backup.log
TAR=/bin/tar
src=${1:-/home}
filename="$(basename $src)-$(date +%H%M)"

if [[ "$EUID" -ne 0 ]];then
	echo "backup.sh must run as root!">>${logpath}
	exit 1
fi

backupdir="/var/backup/$(date +%Y%m%d)/"
if [[ ! -d $backupdir ]];then
	echo "$backupdir doesn't exist,create it...">>${logpath}
	mkdir -pv $backupdir
	echo "done.">>${logpath}
fi


${TAR} -jcvf "${backupdir}${filename}.tar.bz2" ${src}
