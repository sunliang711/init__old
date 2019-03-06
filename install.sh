#!/bin/bash
thisScriptDir=$(cd $(dirname ${BASH_SOURCE}) && pwd)
cd $thisScriptDir
USER=${SUDO_USER:-$(whoami)}
HOME=$(eval echo ~$USER)

usage(){
    echo "Usage: $(basename $0) OPTIONS"
    echo "OPTIONS:"
    echo -e "\t-h                  Print this message"
    echo -e "\t-d                  Install dev apps"
    echo -e "\t-g                  Set git"
    echo -e "\t-s                  Set shell"
    echo -e "\t-l                  local proxy ie: http://localhost:6117"
    echo -e "\t-v whichVIM         Install supervim for whichVIM(vim n(eo)vim or both)"
    echo -e "\t-i                  Install iptables service (need systemd)"
    echo -e "\t-p <URL of proxy>   Using URL as proxy"
    exit 1
}
dev=0
iptables=0
git=0
shell=0
supervim=
proxy=

while getopts ":diglsv:hp:" opt;do
    case "$opt" in
        d)
            dev=1
            ;;
        i)
            if ! command -v systemctl >/dev/null 2>&1;then
                echo "iptables service need systemd"
                exit 1
            fi
            iptables=1
            ;;
        g)
            git=1
            ;;
        s)
            shell=1
            ;;
        v)
            supervim=$(echo $OPTARG|tr 'A-Z' 'a-z')
            ;;
        h)
            usage
            ;;
        l)
            proxy=http://localhost:6117
            ;;
        p)
            proxy=$OPTARG
            ;;
        :)
            echo "Option \"$OPTARG\" need argument"
            echo
            usage
            ;;
        \?)
            echo "Option \"$OPTARG\" not support"
            echo
            usage
            ;;
        *)
            usage
            ;;
    esac
done
if (($#==0));then
    usage
fi

if [[ -n $supervim ]];then
    case $supervim in
        vim|nvim|neovim|both)
            ;;
        *)
            echo "Option: \"-v\" need valid argument!!"
            echo
            usage
            ;;
    esac
fi

if [[ -n "$proxy" ]];then
    echo "Using proxy: $proxy"
    cat<<-EOF>/tmp/proxy
	#shopt -s expand_aliases
	export http_proxy=$proxy
	export https_proxy=$proxy
	export ftp_proxy=$proxy
	export all_proxy=$proxy
	export HTTP_PROXY=$proxy
	export HTTPS_PROXY=$proxy
	export FTP_PROXY=$proxy
	export ALL_PROXY=$proxy
	git config --global http.proxy "$proxy"
	git config --global https.proxy "$proxy"
	#echo "proxy=$proxy" >$HOME/.curlrc
	EOF
fi
#check OS type
version=$(bash linux-version.sh)

echo "Detected the OS is $version"
OS=$(echo $version | awk -F'-' '{print $1}' | tr 'A-Z' 'a-z')
case $OS in
    debian|ubuntu|centos|fedora|arch|manjaro*|mac*)
        ;;
    *)
        echo "Your OS is not support!!"
        exit 1
        ;;
esac

if (($EUID != 0));then
    if ! command -v sudo >/dev/null 2>&1;then
        echo "Not root privilege and no \"sudo\" cmd"
        exit 1
    fi
    #not root privilege
    #1. this user can use sudo cmd
    #the 4th field of file /etc/group is members of a group only on Linux not MacOS
    issudoer=0
    sudo true && issudoer=1
    # case $(uname) in
    #     Darwin)
    #         sudo true && issudoer=1
    #         ;;
    #     Linux)
    ###并不是所有的linux发行版sudo权限都在sudo组里的,有的默认是在wheel组,比如fedora,所以最稳妥的方式还是sudo true命令是否成功执行来判断
    #         members=$(awk -F ':' '/^sudo/ {print $4}' /etc/group)
    #         for u in $(echo $members | tr "," "\n");do
    #             if [[ "$u" == "$USER" ]];then
    #                 issudoer=1
    #             fi
    #         done
    #         ;;
    # esac
    #2. this user cannot use sudo cmd
    if (($issudoer==0));then
        echo "You are not root,and you can not use sudo cmd!!"
        exit 1
    fi
fi


#dev need root
if (($dev == 1));then
    if (($EUID == 0));then
        bash dev/dev-$OS
        bash tmux/install.sh
    else
        sudo bash dev/dev-$OS
        sudo bash tmux/install.sh
    fi
fi

#iptables need root
if (($iptables == 1));then
    if (($EUID == 0));then
        bash service/iptablesService/install.sh
    else
        sudo bash service/iptablesService/install.sh
    fi

fi

#git for current user
if (($git == 1));then
    bash git/setGit
fi

#shell for current user
if (($shell == 1));then
    bash shell/10-zsh-installer.sh && bash shell/20-set-zsh-theme.sh && bash shell/30-config-shell.sh install
fi


#vim for current user
case $supervim in
    vim)
        if [[ -n "$proxy" ]];then
            bash supervim/install.sh -f -p $proxy vim
        else
            bash supervim/install.sh -f vim
        fi
        ;;
    nvim|neovim)
        if [[ -n "$proxy" ]];then
            bash supervim/install.sh -f -p $proxy nvim
        else
            bash supervim/install.sh -f nvim
        fi

        ;;
    both)
        if [[ -n "$proxy" ]];then
            bash supervim/install.sh -f -p $proxy vim
            bash supervim/install.sh -f -p $proxy nvim
        else
            bash supervim/install.sh -f vim
            bash supervim/install.sh -f nvim
        fi
        ;;
esac


##TODO 1.save old config 2.restore old config
#cleanup
git config --global --unset-all http.proxy
git config --global --unset-all https.proxy
if [ -e $HOME/.curlrc ];then
    rm $HOME/.curlrc
fi
if [ -e /tmp/proxy ];then
    rm /tmp/proxy
fi
