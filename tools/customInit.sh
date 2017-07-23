#!/bin/bash

if [[ $EUID -ne 0 ]];then
	echo "Must be run as root"
	exit 1
fi
#debian和ubuntu是一样的处理方式
if uname -a | /bin/grep  -q -i 'ubuntu\|debian';then
    os='ubuntu'
else
    os='noubuntu'
fi

#write line to file
write(){
line=${1}
if [[ "" != $line ]];then
	echo $line >> $path
fi
}

#check if already written
alreadyWritten(){
if /bin/grep -q '#already written' $path;then
	exit 1
fi
}

#path is the destination where the config lines will go to
#default path is /etc/bashrc
if [[ $os == 'ubuntu' ]];then
    path=${1:-"/etc/bash.bashrc"}
else
    path=${1:-"/etc/bashrc"}
fi

#check file existence
if [[ ! -f "$path" ]];then
	echo "$path does not exist"
	exit 1
fi

alreadyWritten

#backup old file
/bin/cp $path $path.old

write '#already written'
write "set -o vi"
write "alias halt='shutdown -h now'"
write "alias la='ls -a'"
write "alias lA='ls -A'"
write "alias cd..='cd ..'"
write "alias cd-='cd -'"
write "alias vi='vim'"

write 'export LS_COLORS=$LS_COLORS:"di=0;33:"'
write "export PS1='[\u@\h \[\e[32;1m\]\W\\$\e[0m'"
#write "export TERM=linux"

exit 0
