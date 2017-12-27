#!/bin/bash
thisScriptDir=$(cd $(dirname ${BASH_SOURCE}) && pwd)
cd ${thisScriptDir}

usage(){
    echo "Usage: $(basename $0) [OPTIONS] [VIM]"
    echo "OPTIONS:"
    echo -e "\t\t-h                     Print this help message"
    echo -e "\t\t-l                     Using http://localhost:8118 as proxy"
    echo -e "\t\t-p [URL of proxy]      Using URL of proxy as proxy"
    echo -e "\t\t-f                     Install font-hack-nerd-font on MacOS"
    echo -e "\t\t-g                     Install vim-go plugin"
    echo -e "\t\t-y [clang|golang|both] Install YouCompleteMe plugin for clang or golang or both"
    echo -e "\t\t-d                     Download From NAS"
    echo
    echo "VIM:"
    echo -e "\t\tvim or nvim( or neovim)            Install plugin for vim or nvim"
    exit 1
}

needCmd(){
    cmd=$1
    if [[ -n $cmd ]];then
        if ! command -v $cmd >/dev/null 2>&1;then
            echo "Error: Need cmd \"$cmd\"!!"
            exit 1
        fi
    fi
}

installFont(){
    case $(uname) in
        "Linux")
            if fc-list | grep -iq Powerline;then
                return
            fi

            if [ ! -d ~/.local/share/fonts ];then
                mkdir -pv ~/.local/share/fonts
            fi
            cp ./fonts/PowerlineSymbols.otf ~/.local/share/fonts
            cp ./fonts/Droid\ Sans\ Mono\ for\ Powerline\ Nerd\ Font\ Complete.otf ~/.local/share/fonts
            fc-cache -vf ~/.local/share/fonts

            if [ ! -d ~/.config/fontconfig/conf.d ];then
                mkdir -pv ~/.config/fontconfig/conf.d
            fi
            cp ./fonts/10-powerline-symbols.conf ~/.config/fontconfig/conf.d
            ;;
        "Darwin")
            command -v brew >/dev/null 2>&1 || { echo "Need install homebrew first!"; exit 1; }
            if ! brew cask list font-hack-nerd-font>/dev/null 2>&1;then
                brew tap caskroom/fonts
                brew cask install font-hack-nerd-font
            fi
            echo "set Knack nerd font in iterm"
            ;;
        MINGW32*)
            echo "Please install nerd font manually."
            ;;
        *)
            echo "Unknown OS,install font failed!" >& 2
            ;;
    esac
}
installBasic(){
    needCmd curl
    uninstall

    mkdir -pv $root/autoload
    mkdir -pv $root/plugins

    #copy color scheme
    cp -r colors $root
    #copy ftplugin
    cp -r ftplugin $root

    echo  "Downloading vim-plug from github..."
    curl -fLo $root/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || { echo "download vim-plug failed.";uninstall; exit 1; }
    cp  init.vim $cfg
}

uninstall(){
    echo "Uninstall.."
    rm -rf $root
    rm -f $cfg
}

proxy=
vimGo=0
ycm=
font=0
downloadFromNAS=0
while getopts ":hlp:fgy:d" opt;do
    case "$opt" in
        h)
            usage
            ;;
        l)
            proxy="http://localhost:8118"
            ;;
        p)
            proxy=$(echo "$OPTARG" | tr 'A-Z' 'a-z')
            ;;
        f)
            font=1
            ;;
        g)
            vimGo=1
            ;;
        y)
            ycm=$(echo "$OPTARG" | tr 'A-Z' 'a-z')
            ;;
        d)
            downloadFromNAS=1
            ;;
        :)
            echo "Options \"$OPTARG\" missing argument!!"
            echo
            usage
            ;;
        \?)
            echo "Options \"$OPTARG\" not support!!"
            echo
            usage
            ;;
    esac
done
#check ycm type
if [[ -n "$ycm" ]];then
    case $ycm in
        clang)
            echo "Install YouCompleteMe for language clang."
            needCmd cmake
            needCmd clang
            needCmd python3
            ;;
        golang)
            needCmd cmake
            needCmd clang
            needCmd python3
            needCmd go
            echo "Install YouCompleteMe for language golang."
            ;;
        both)
            echo "Install YouCompleteMe for language golang and clang."
            needCmd cmake
            needCmd clang
            needCmd python3
            needCmd go
            ;;
        *)
            echo "YouCompleteMe plugin valid type: clang golang both"
            echo
            usage
            ;;
    esac
fi
if (($vimGo==1));then
    needCmd go
fi
shift $((OPTIND-1))
USER=${SUDO_USER:-$(whoami)}
HOME=$(eval echo ~$USER)
root=
cfg=
whichVim=$(echo $1 | tr 'A-Z' 'a-z')
case $whichVim in
    nvim|neovim)
        needCmd nvim
        root="$HOME/.config/nvim"
        cfg="$root/init.vim"
        ;;
    vim)
        needCmd vim
        # needCmd bc
        vimVersion=$(vim --version | head -1 | awk '{print $5}')
        root="$HOME/.vim"
        major=$(echo $vimVersion | awk -F. '{print $1}')
        minor=$(echo $vimVersion | awk -F. '{print $2}')
        if [[ -z $major ]] || [[ -z $minor ]];then
            echo "vim version is wrong!!"
            exit 1
        fi
        # if (( $(echo "$vimVersion>=7.4" | bc -l) ));then
        if (( $major >= 7 && $minor >= 4 ));then
            cfg="$root/vimrc"
        else
            cfg="$HOME/.vimrc"
        fi
        ;;
    *)
        echo "Valid vim type are: vim nvim"
        echo
        usage
esac

##################################################
#Print some message
if [[ -n $proxy ]];then
    echo "Using proxy: $proxy"
fi
echo "Vim type: $whichVim"
if [[ -n "$vimVersion" ]];then
    echo "Vim version: $vimVersion"
fi
echo "USER: $USER"
echo "HOME: $HOME"
echo "$whichVim etc directory: $root"
echo "$whichVim etc file: $cfg"
if (($vimGo==1));then
    echo "Install plugin vim-go"
fi
if (($downloadFromNAS==1));then
    echo "Download from NAS"
fi

#set proxy
if [[ -n $proxy ]];then
    echo "Set proxy for git,curl,brew"
    shopt -s expand_aliases
    git config --global http.proxy "$proxy"
    git config --global https.proxy "$proxy"
    alias curl="curl -x $proxy"
    alias brew="ALL_PROXY=$proxy brew"
    export http_proxy=$proxy
    export https_proxy=$proxy
    export ftp_proxy=$proxy
    export HTTP_PROXY=$proxy
    export HTTPS_PROXY=$proxy
    export FTP_PROXY=$proxy
fi

#Install font
if (($font==1));then
    case $(uname) in
        Darwin)
            needCmd brew
            echo "Install font-hack-nerd-font on MacOS"
            installFont
            ;;
        Linux)
            echo "Install nerd font on Linux"
            installFont
            ;;
        *)
            echo "Only Install font on Linux and MacOS"
            echo
            usage
            ;;
    esac
fi

#TODO 'needCmd curl' if using curl to download
#TODO 'needCmd git' if using git to download

installBasic

#install YouCompleteMe
if [[ -n "$ycm" ]];then
    #1 去掉注释
    sed -ibak "s|\"[ ]*\(Plug 'Valloric/YouCompleteMe'\)|\1|" $cfg
    rm -f "${cfg}bak"
    case $whichVim in
        vim|neovim)
            dest="$HOME/.config/nvim/plugins/YouCompleteMe"
            ;;
        nvim)
            dest="$HOME/.vim/plugins/YouCompleteMe"
            ;;
    esac
    if [[ "$downloadFromNAS" -eq 1 ]];then
        echo "Download YouCompleteMe from NAS..."
        \curl -L -o YouCompleteMe.tar.gz http://home.eagle711.win:5000/fbsharing/I0CloRro
        echo "Extract YouCompleteMe..."
        tar -C $root/plugins -xf YouCompleteMe.tar.gz
        rm -rf YouCompleteMe.tar.gz
    fi
fi

if (($vimGo==1));then
    echo "modify $cfg for vim-go"
    sed -ibak "s|\"[ ]*\(Plug 'fatih/vim-go'\)|\1|" $cfg
    rm -f "${cfg}bak"
    echo "Set GOPATH to ~/go"
    export GOPATH=~/go
    if [[ ! -d $GOPATH ]];then
        mkdir -pv $GOPATH
    fi
    if [[ "$downloadFromNAS" -eq 1 ]];then
        echo "Download vim-go source from NAS..."
        \curl -L -o vimgosrc.tar.gz http://home.eagle711.win:5000/fbsharing/OHdvYwf9
        echo "Extract..."
        tar -C $GOPATH -xf vimgosrc.tar.gz
        rm -rf vimgosrc.tar.gz
    fi
fi

echo "Install plugins..."
$whichVim -c PlugInstall -c qall

if [[ -n $ycm ]];then
    echo "Install YouCompleteMe..."
    if [ -d "$dest" ];then
        cd "$dest"
        option=
        case $ycm in
            clang)
                option+=" --clang-completer "
                option+=" --system-libclang "
                ;;
            golang)
                option+=" --gocode-completer "
                ;;
            both)
                option+=" --clang-completer "
                option+=" --system-libclang "
                option+=" --gocode-completer "
                ;;
        esac
        #./install.py  --gocode-completer --clang-completer --system-libclang
        eval python3 ./install.py  "$option" || { echo "Install YouCompleteMe failed."; exit 1; }
    else
        echo "Doesn't exist $dest"
        exit 1
    fi
fi

if (($vimGo==1));then
    echo "Install vim-go..."
    #$whichVim +GoInstallBinaries +qall
    $whichVim -c GoInstallBinaries -c qall
    templateFile=$(find $root -name hello_world.go)
    SED=sed
    if [[ "$(uname)" == "Darwin" ]];then
        SED=gsed
    fi
    $SED -ibak  's|"fmt"|(\n    &\n)|' "$templateFile"
    rm "$templateFile"bak
fi
