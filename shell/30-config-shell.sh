#!/bin/bash
if [ -e /tmp/proxy ];then
    source /tmp/proxy
fi
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPTDIR"

USAGE="usage: $(basename $0) {install|uninstall|reinstall}"
if (($# == 0));then
    echo "$USAGE" >& 2
    exit 0
fi

if (($EUID!=0));then
    #非root用户的时候,需要检测是否有sudo命令,如果有还要检测当前用户可以使用sudo命令
    #因为下面需要把shellrc复制到/etc,这要求root权限
    if command -v sudo >/dev/null 2>&1;then
        sudo true || { echo "Error: Current user cannot use sudo cmd!";exit 1; }
    else
        echo "Error: Current user is not root,and can not find sudo cmd!"
        exit 1
    fi
fi

OS=""
case $(uname) in
    "Darwin")
        OS="darwin"
        ;;
    "Linux")
        OS="linux"
        ;;
    *)
        echo "Unknown os,Quit!"
        exit 1;;
esac


startLine="##CUSTOM BEGIN"
endLine="##CUSTOM END"

user=${SUDO_USER:-$(whoami)}
HOME=$(eval echo ~$user)

install(){
    case $(uname) in
        Darwin)
            # macOS uses libedit, 'bind -v' set vi mode,such as python interactive shell,mysql
            if [ ! -e "$HOME/.editrc" ] || ! grep -q 'bind -v' "$HOME/.editrc";then
                echo 'bind -v' >> "$HOME/.editrc"
            fi
            ;;
        Linux)
            # Linux uses readline library,'set editing-mode vi' set vi mode
            if [ ! -e "$HOME"/.inputrc ] || ! grep -q 'set editing-mode vi' "$HOME/.inputrc";then
                echo 'set editing-mode vi' >> "$HOME/.inputrc"
            fi

            (crontab -l 2>/dev/null;echo "*/5 * * * * /usr/local/bin/tools/pullInit.sh")
            ;;
    esac
    shell=${1:?"missing shell type"}
    case "$shell" in
        bash)
            if [[ "$OS" == linux ]];then
                cfgFile=$HOME/.bashrc
            else
                #mac os
                cfgFile=$HOME/.bash_profile
            fi
            ;;
        zsh)
            cfgFile=$HOME/.zshrc
            ;;
        *)
            echo -e "Only support bash or zsh! ${RED}\u2717${RESET}"
            exit 1
            ;;
    esac
    #install custom config
    #the actual config is in file ~/.bashrc(for linux) or ~/.bash_profile(for mac)

    #grep for $startLine quietly
    if grep  -q "$startLine" $cfgFile;then
        echo "Already installed,Quit! (or use reinstall to reinstall)"
        exit 1
    else
        echo "Install setting of $shell..."
        rc=/etc/shellrc
        if [ ! -e $rc ];then
            echo "copy shellrc to $rc"
            if (($EUID!=0));then
                # sudo cp shellrc  $rc
                sudo ln -sf "$SCRIPTDIR"/shellrc $rc
            else
                # cp shellrc  $rc
                ln -sf "$SCRIPTDIR"/shellrc $rc
            fi
        fi
        #insert header
        echo "$startLine" >> $cfgFile
        #insert body
        echo "[ -f $rc ] && source $rc" >> $cfgFile
        #insert tailer
        echo "$endLine" >> $cfgFile

        #link tools to /usr/local/bin/tools
        if (($EUID!=0));then
            sudo ln -sf $SCRIPTDIR/tools /usr/local/bin
        else
            ln -sf $SCRIPTDIR/tools /usr/local/bin
        fi
        echo "Done."
    fi
}

uninstall(){
    shell=${1:?"missing shell type"}
    case "$shell" in
        bash)
            if [[ "$OS" == linux ]];then
                cfgFile=$HOME/.bashrc
            else
                #mac os
                cfgFile=$HOME/.bash_profile
            fi
            ;;
        zsh)
            cfgFile=$HOME/.zshrc
            ;;
        *)
            echo -e "Only support bash or zsh! ${RED}\u2717${RESET}"
            exit 1
            ;;
    esac
    echo "Uninstall setting of $shell..."
    #uninstall custom config
    #delete lines from header to tailer
    sed -ibak -e "/$startLine/,/$endLine/ d" $cfgFile
    rm ${cfgFile}bak
    if [ -e /etc/shellrc ];then
        if (($EUID!=0));then
            sudo rm /etc/shellrc
            sudo rm /usr/local/bin/tools
        else
            rm /etc/shellrc
            rm /usr/local/bin/tools
        fi
    fi

    echo "Done."
}

reinstall(){
    uninstall bash
    uninstall zsh
    install bash
    install zsh
}

case "$1" in
    install | ins*)
        install bash
        install zsh
        exit 0
        ;;
    uninstall | unins*)
        uninstall bash
        uninstall zsh
        exit 0
        ;;
    reinstall | reins*)
        reinstall
        exit 0
        ;;
    --help | -h | --h* | *)
        echo "$USAGE" >& 2
        exit 0
        ;;
esac
