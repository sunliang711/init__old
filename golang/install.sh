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
    OPTIND=1
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

localDest=$HOME/.go
globalDest=/usr/local/go
dest=${globalDest}
downloadDest=/tmp
version=1.13.8
executables=(go gofmt)
local=0

winlink='https://dl.google.com/go/goVERSION.windows-amd64.msi'
maclink='https://dl.google.com/go/goVERSION.darwin-amd64.pkg'
linuxlink='https://dl.google.com/go/goVERSION.linux-amd64.tar.gz'
golink=

usage(){
    cat<<EOF
Usage: $(basename $0) option

option:
    -l  install golang to $localDest instead of $globalDest
    -v  <version> install specify version of golang,default version: $version

note:
     On MacOS, just download golang installer to ${downloadDest}
EOF
    exit 1
}


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

while getopts ":lv:t:h" opt;do
    case "$opt" in
        l)
            dest=$localDest
            local=1
            ;;
        v)
            version=$OPTARG
            ;;
        h)
            usage
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

cd ${downloadDest}

if ! command -v curl >/dev/null 2>&1;then
    echo "Need curl!"
    exit 1
fi

if [ ! -e "$fileName" ];then
    echo "Download link: $golink"
    echo "Downloading ..."
    curl -LO "$golink" || { echo "Download golang failed!"; exit 1; }
fi

case $(uname) in
    Darwin)
        echo "Golang has been downloaded to ${downloadDest}"
        exit 0
        ;;
    Linux)
        ;;
esac

#check dest
if [ ! -d "$dest" ];then
    echo "mkdir $dest..."
    if (( $local == 1 ));then
        mkdir -pv $dest
    else
        runAsRoot "mkdir -pv $dest"
    fi
fi

echo "extract $fileName..."
tar -xvf "$fileName" >/dev/null 2>&1 || { echo "extract ${fileName} failed.";exit 1; }

if [ -d "$dest/$version" ];then
    echo "$dest/$version already exist, delete it? [y/n]"
    read deleteOld
    if [ "$deleteOld" = "y" ];then
        if (( $local == 1 ));then
            rm -rf $dest/$version
            mkdir -pv "$dest/$version"
        else
            runAsRoot "rm -rf $dest/$version"
            runAsRoot "mkdir -pv $dest/$version"
        fi
    else
        echo "Quit."
        exit 1
    fi
else
    if (( $local == 1 ));then
        mkdir -pv "$dest/$version"
    else
        runAsRoot "mkdir -pv $dest/$version"
    fi
fi

cd go/bin
for exe in "${executables[@]}";do
    if (( "$local" == 1 ));then
        install -m 755 "$exe" "$dest/$version"
    else
        runAsRoot "install -m 755 $exe $dest/$version"
    fi
done

rm -rf "$downloadDest/go"

if (( "$local" == 1 ));then
    gvm.sh -l -v $version
else
    gvm.sh -v $version
fi
