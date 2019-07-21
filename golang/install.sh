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
    cat<<'EOF'
Usage: $(basename $0) option

option:
    -g  install golang to /usr/local/golang,else to $HOME/.golang
    -v  <version> install specify version of golang
EOF
    exit 1
}

dest=$home/.golang
version=1.12.7

winlink='https://dl.google.com/go/goVERSION.windows-amd64.msi'
maclink='https://dl.google.com/go/goVERSION.darwin-amd64.pkg'
linuxlink='https://dl.google.com/go/goVERSION.linux-amd64.tar.gz'

golink=
case $(uname) in
    Darwin)
        golink="$maclink"
        ;;
    Linux)
        golink="$linuxlink"
        ;;
    *)
        usage
        ;;
esac

while getopts ":gv:t:" opt;do
    case "$opt" in
        g)
            dest=/usr/local/golang
            if (($EUID!=0));then
                echo "when install to global position,run this script as root."
                exit 1
            fi
            ;;
        v)
            version=$OPTARG
            ;;
        t)
            case $OPTARG in
                linux)
                    golink="$linuxlink"
                    ;;
                Darwin)
                    golink="$maclink"
                    ;;
                *)
                    usage
            esac
            ;;
        :)
            echo "Missing parameter for option: \"$OPTARG\""
            usage
            ;;
        \?)
            echo "Unknown option: \"$OPTARG\""
            usage
            ;;
    esac
done


#check version
echo "golang version: $version"

golink="$(echo "$golink" | perl -pe "s|VERSION|$version|")"
fileName=${golink##*/}
echo "fileName: $fileName"

cd /tmp

if [ ! -e "$fileName" ];then
    echo "Download link: $golink"
    echo "Downloading ..."
    curl -LO "$golink" || { echo "Download golang failed!"; exit 1; }
fi

case $(uname) in
    Darwin)
        echo "golang has been downloaded"
        exit 0
        ;;
    Linux)
        ;;
esac

#check dest
if [ ! -d "$dest" ];then
    echo "mkdir $dest..."
    mkdir -pv $dest
fi

tar -xvf "$fileName" || { echo "extract file failed.";exit 1; }

if [ -d "$dest/$version" ];then
    echo "$dest/$version already exist, delete it? [y/n]"
    read deleteOld
    if [ "$deleteOld" = "y" ];then
        rm -rf $dest/$version/*
    else
        echo "Quit."
        exit 1
    fi
else
    mkdir -pv "$dest/$version"
fi

mv go/* $dest/$version
rm -rf go

