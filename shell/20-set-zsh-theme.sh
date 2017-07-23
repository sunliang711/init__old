#!/bin/bash

if [ ! -d ~/.oh-my-zsh ];then
    echo -e "Cann't find oh-my-zsh direcotry!$(tput setaf 1)\u2717"
    exit 1
fi
cp *.zsh-theme ~/.oh-my-zsh/themes
sed -ibak 's/\(ZSH_THEME=\).\{1,\}/\1"zeta"/' ~/.zshrc
rm ~/.zshrcbak
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ];then
    echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
fi
