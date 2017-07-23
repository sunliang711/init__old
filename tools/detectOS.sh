#!/bin/bash
# 检测出当前系统的版本，形如ubuntu-16.10,archlinux,fedora-23,centos-6.8,debian-8,macos
currentOS(){
    case "$(uname)" in
        "Linux")
            #pacman -> archlinux
            if command -v pacman >/dev/null 2>&1;then
                echo "archlinux"

            #apt-get -> debian or ubuntu
            elif command -v apt-get >/dev/null 2>&1;then
                #get version info from lsb_release -a
                #lsb_release -a命令会有个错误输出No LSB modules are available.把这个丢弃使用 2>/dev/null
                lsb=$(lsb_release -a 2>/dev/null)
                distributor=$(echo "$lsb" | grep 'Distributor ID' | grep -oP ':.*' | grep -oP '\w+')
                if [[ "$distributor" == "Ubuntu" ]];then
                    echo "$lsb" | grep "Description" | awk -F: '{print $2}' | awk '{print $1"-"$2}'
                elif [[ "$distributor" == "Debian" ]];then
                    release=$(echo "$lsb" | grep 'Release' | grep -oP ':.*' | grep -oP '\d.+')
                    echo "$distributor-$release"
                else
                    echo "error(not ubuntu or debian)"
                fi
            #yum -> centos or fedora
            elif command -v yum >/dev/null 2>&1;then
                #TODO
                echo 'yum'
            fi
            ;;
        "Darwin")
            echo "macos"
            ;;
        *)
            echo "error"
            ;;
    esac
}
