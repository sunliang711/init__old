#!/bin/bash
if [ -e /tmp/proxy ];then
    source /tmp/proxy
fi
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPTDIR"

origin=0
if [ $1="-o" ];then
    origin=1
fi

user=${SUDO_USER:-$(whoami)}
HOME=$(eval echo ~$user)
if [ ! -d $HOME/.oh-my-zsh ];then
    echo -e "Cann't find oh-my-zsh direcotry!$(tput setaf 1)\u2717"
    exit 1
fi
cp *.zsh-theme $HOME/.oh-my-zsh/themes
sed -ibak 's/\(ZSH_THEME=\).\{1,\}/\1"zeta"/' $HOME/.zshrc
rm $HOME/.zshrcbak
#install zsh-syntax-highlighting
if [[ ! -d $HOME/.zsh-syntax-highlighting ]];then
    if (($origin==1));then
        echo "clone from github.com..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh-syntax-highlighting
    else
        echo "clone from gitee.com..."
        git clone https://gitee.com/sunliang711/zsh-syntax-highlighting.git $HOME/.zsh-syntax-highlighting
    fi
fi
echo "source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> $HOME/.zshrc

