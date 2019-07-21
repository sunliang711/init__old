#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
root="$(cd $(dirname $rpath) && pwd)"
cd "$root"

user="${SUDO_USER:-$(whoami)}"
home="$(eval echo ~$user)"

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
cyan=$(tput setaf 5)
reset=$(tput sgr0)
runAsRoot(){
    verbose=0
    while getopts ":v" opt;do
        case "$opt" in
            v)
                verbose=1
                ;;
            \?)
                echo "Unknown option: \"$OPTARG\""
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    cmd="$@"
    if [ -z "$cmd" ];then
        echo "${red}Need cmd${reset}"
        exit 1
    fi

    if [ "$verbose" -eq 1 ];then
        echo "run cmd:\"${red}$cmd${reset}\" as root."
    fi

    if (($EUID==0));then
        sh -c "$cmd"
    else
        if ! command -v sudo >/dev/null 2>&1;then
            echo "Need sudo cmd"
            exit 1
        fi
        sudo sh -c "$cmd"
    fi
}

usage(){
    cat<<EOF
Usage: $(basename $0) option

option:
    -v  <version> switch to specify version of golang
    -g  switch globally,need root priviledge
EOF
    exit 1
}

dest=$home/.golang
version=unknown

while getopts ":v:gh" opt;do
    case "$opt" in
        h)
            usage
            ;;
        v)
            version=$OPTARG
            ;;
        g)
            dest=/usr/local/golang
            if (($EUID!=0));then
                echo "Need run as root when swith globally."
                usage
            fi
            ;;
        :)
            ;;
        \?)
            ;;
    esac
done

echo "version: $version"
if [ ! -d "$dest/$version" ];then
    echo "No such version"
    usage
    exit 1
fi
ln -sf "$dest/$version" "$dest/current"
