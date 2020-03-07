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

usage(){
    cat<<EOF
Usage: $(basename $0) option

option:
    -v  <version> switch to specify version of golang
    -l  switch globally,need root priviledge
EOF
    exit 1
}


globalPATH=/usr/local/bin
localDest=$HOME/.go
globalDest=/usr/local/go
dest=${globalDest}
version=
local=0
executables=(go gofmt)

while getopts ":v:lhs" opt;do
    case "$opt" in
        h)
            usage
            ;;
        v)
            version=$OPTARG
            ;;
        l)
            dest=$localDest
            local=1
            ;;
        :)
            ;;
        \?)
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$version" ];then
    echo "Need version"
    echo -n "Installed version[s]: "
    ls $dest/ 2>/dev/null| grep -v current
    echo
    usage
fi

echo "version: $version"
if [ ! -d "$dest/$version" ];then
    echo "No such version in \"$dest\""
    echo -n "Installed version[s]: "
    ls $dest/ 2>/dev/null| grep -v current
    echo
    exit 1
fi

if [ -d "$dest/current" ];then
    if (( $local == 1 ));then
        rm -rf "$dest/current"
    else
        runAsRoot "rm -rf $dest/current"
    fi
fi

if (( $local == 1 ));then
    ln -svf "$dest/$version" "$dest/current"
else
    runAsRoot "ln -svf $dest/$version $dest/current"
fi

if (( $local == 1 ));then
    echo "Add $dest/current to your PATH manaually."
else
    echo "link executables in $dest/current to $globalPATH..."
    for exe in "${executables[@]}";do
        runAsRoot "ln -svf $dest/current/$exe $globalPATH"
    done
fi
