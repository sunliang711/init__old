#!/bin/bash
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPTDIR"

user=${SUDO_USER:-$(whoami)}
if [ ! -d ~$user/.oh-my-zsh ];then
    echo -e "Cann't find oh-my-zsh direcotry!$(tput setaf 1)\u2717"
    exit 1
fi
cp *.zsh-theme ~$user/.oh-my-zsh/themes
sed -ibak 's/\(ZSH_THEME=\).\{1,\}/\1"zeta"/' ~$user/.zshrc
rm ~$user/.zshrcbak
#install zsh-syntax-highlighting
cd ~$user
if [[ ! -d .zsh-syntax-highlighting ]];then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git .zsh-syntax-highlighting
fi
echo "source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~$user/.zshrc
cd - >/dev/null 2>&1

