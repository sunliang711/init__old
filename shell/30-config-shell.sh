#!/bin/bash
if [ -e /tmp/proxy ];then
    source /tmp/proxy
fi
rpath="$(readlink $BASH_SOURCE)"
if [ -z "$rpath" ];then
    rpath="$BASH_SOURCE"
fi
root="$(cd $(dirname $rpath) && pwd)"
cd "$root"
user=${SUDO_USER:-$(whoami)}
home=$(eval echo ~$user)

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
cyan=$(tput setaf 5)
reset=$(tput sgr0)
runAsRoot(){
    cmd="$@"
    if [ -z "$cmd" ];then
        echo "${red}Need cmd${reset}"
        exit 1
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
startLine="##CUSTOM BEGIN"
endLine="##CUSTOM END"

usage(){
    cat<<-EOF
Usage: $(basename $0) CMD

CMD:
    install     bash|zsh
    uninstall   bash|zsh
EOF
    exit 1
}

bashrc="${home}/.bashrc"
zshrc="${home}/.zshrc"
globalrc=/etc/shellrc

install(){
    local type=${1}
    if [ -z "$type" ];then
        usage
    fi
    case $type in
        bash)
            configFile="$bashrc"
            ;;
        zsh)
            configFile="$zshrc"
            ;;
        *)
            usage
            ;;
    esac
    case $(uname) in
        Darwin)
            # macOS uses libedit, 'bind -v' set vi mode,such as python interactive shell,mysql
            if [ ! -e "$home/.editrc" ] || ! grep -q 'bind -v' "$home/.editrc";then
                echo 'bind -v' >> "$home/.editrc"
            fi
            ;;
        Linux)
            # Linux uses readline library,'set editing-mode vi' set vi mode
            if [ ! -e "$home"/.inputrc ] || ! grep -q 'set editing-mode vi' "$home/.inputrc";then
                echo 'set editing-mode vi' >> "$home/.inputrc"
            fi
            ;;
    esac
    runAsRoot ln -sf "$root/tools" /usr/local/bin
    if grep -q "$startLine" "$configFile";then
        echo "Already exist."
        exit 0
    else
        if [ ! -e $"globalrc" ];then
            echo "link shellrc to $globalrc"
            runAsRoot ln -sf "$root/shellrc" $globalrc
        fi

        echo "$startLine" >> "$configFile"
        echo "[ -f $globalrc ] && source $globalrc" >> "$configFile"
        echo "$endLine" >> "$configFile"
        echo "Done."
    fi
}

uninstall(){
    local type=${1}
    if [ -z "$typ3" ];then
        usage
    fi
    case $type in
        bash)
            configFile="$bashrc"
            ;;
        zsh)
            configFile="$zshrc"
            ;;
        *)
            usage
            ;;
    esac
    case $(uname) in
        Darwin)
            if [ -e "$home/.editrc" ];then
                sed -i.bak '/bind -v/d' $home/.editrc
                rm $home/.editrc.bak
            fi
            ;;
        Linux)
            if [ -e "$home/.inputrc" ];then
                sed -i '/set editing-mode vi/d' $home/.inputrc
            fi
            ;;
    esac
    runAsRoot rm $globalrc
    runAsRoot rm /usr/local/bin/tools

    sed -ibak -e "/$startLine/,/$endLine/ d" "$configFile"
}

cmd=$1
shift

case $cmd in
    install)
        install "$@"
        ;;
    uninstall)
        uninstall "$@"
        ;;
    *)
        usage
        ;;
esac
