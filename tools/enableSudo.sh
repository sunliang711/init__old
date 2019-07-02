#!/bin/bash
if (($EUID!=0));then
    echo "MUST run as root."
    exit 1
fi

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

user=${1}
if [ -z "$user" ];then
    if [ -n "${SUDO_USER}" ];then
        user="${SUDO_USER}"
        echo -n "Enable user:$user ?[y/n] "
        read xx
        if [ $xx = "n" ];then
            echo "${red}Exit${reset}."
            exit 1
        fi
    fi
fi

echo "Enable user:${green}$user${reset} to sudo nopass permission..."
customRule=/etc/sudoers.d/nopass
cat<<EOF>>"$customRule"
$user ALL=(ALL:ALL) NOPASSWD:ALL
EOF

sort "$customRule" | uniq > "${customRule}.tmp" && mv "${customRule}.tmp" "${customRule}"

echo "${green}Done.${reset}"
