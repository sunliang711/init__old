#!/usr/bin/env bash

needCmd(){
    cmd=$1
    if [[ -n $cmd ]];then
        if ! command -v $cmd >/dev/null 2>&1;then
            echo "Error: Need cmd \"$cmd\"!!"
            exit 1
        fi
    fi
}

installDir(){
    if [ -d "$1" ] && [ -d "$2" ];then
        echo "copy $1 -> $2..."
        cp -r "$1" "$2"
    fi
}


install(){
    if [ "$font" -eq "1" ];then
        bash ./installFont.sh || { echo "Install font error."; }
    fi

    installDir colors   " $root "
    installDir ftplugin " $root "

    ## Download vim-plug
    if (($origin==1));then
        echo  "Downloading vim-plug from github..."
        curl -fLo $root/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || { echo "download vim-plug failed.";uninstall; exit 1; }
    else

        echo  "Downloading vim-plug from gitee..."
        echo "$(tput setaf 1)Make sure not use git proxy!!$(tput sgr0)"
        curl -fLo $root/autoload/plug.vim --create-dirs \
            https://gitee.com/sunliang711/vim-plug/raw/master/plug.vim || { echo "download vim-plug failed.";uninstall; exit 1; }
        #use gitee.com repo (in China!!)
        sed -ibak -e 's|github.com/junegunn|gitee.com/sunliang711|g' -e 's|github\.com|gitee.com|g'  -e 's|github\\\.com|gitee\\.com|g' $root/autoload/plug.vim
    fi


    ## fill plugins to vimrc(init.vim)
    # source ./allPlugins.sh || { echo "load allPlugins.sh error"; exit 1; }

    ### header
    cat ./header.vim > $cfg

    ### user choose plugins
    echo "## Set plugin name to 1 to install it." > choice.user
    for i in plugins/*;do
        printf "%-25s =    0\n" $(basename $i)
    done >> choice.user
    $VIM choice.user

    declare -a toBeInstalledPlugins
    # vimrc (init.vim) plugin item
    while read -r line;do
        if echo "$line" | grep -q '^[ \t]*#';then
            # ignore comment
            continue
        fi

        enable=$(echo "$line" | perl -ne 'print $1 if /^\s*(\S+)\s*=\s*1\s*$/')
        if [ -n "$enable" ];then
            toBeInstalledPlugins+=("$enable")
        fi
    done < choice.user
    rm choice.user

    for name in "${toBeInstalledPlugins[@]}";do
        echo "Debug plugin name: $name"
        perl -pe "s|(Plug ').+(/.+)|\1sunliang711\2|" "plugins/$name" >> "$cfg"
    done
    echo  >> "$cfg"
    echo "call plug#end()" >> "$cfg"

    echo  >> "$cfg"
    echo  >> "$cfg"

    ## vimrc (init.vim) plugin settings
    for name in "${toBeInstalledPlugins[@]}";do
        if [ -f  "pluginSettings/$name" ];then
            cat "pluginSettings/$name" >> "$cfg"
        fi
    done



    echo "Install plugin..."
    $VIM -c PlugInstall -c qall

    # export VIM for script use
    export VIM
    export root
    ## plugin script
    for name in "${toBeInstalledPlugins[@]}";do
        if [ -f "pluginScripts/$name" ];then
            echo "run pluginScripts/$name"
            bash "pluginScripts/$name"
        fi
    done
    echo "done."


}

usage(){
    cat<<EOF
Usage: $(basename $0) [options] <vim/nvim>

options:
        -f              install nerd font used by color theme
        -o              install plugin from original source(github.com),instead of gitee.com
EOF
exit 1
}

## begin
font=0
origin=0
root=
cfg=
choiceFile="choice"


while getopts ":fo" opt;do
    case $opt in
        f)
            font=1
            ;;
        o)
            origin=1
            ;;
        :)
            echo "Option '$OPTARG' need argument"
            exit 1
            ;;
        \?)
            ehco "Unknown option: '$OPTARG'"
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

needCmd curl

VIM=$1
case $VIM in
    nvim)
        needCmd nvim
        root="$HOME/.config/nvim"
        cfg="$root/init.vim"
        ;;
    vim)
        needCmd vim
        vimVersion=$(vim --version | head -1 | awk '{print $5}')
        root="$HOME/.vim"
        major=$(echo $vimVersion | awk -F. '{print $1}')
        minor=$(echo $vimVersion | awk -F. '{print $2}')
        if [[ -z $major ]] || [[ -z $minor ]];then
            echo "Cannot get vim version!"
            exit 1
        fi
        if (( $major == 7 && $minor >= 4 )) || (( $major > 7 ));then
            cfg="$root/vimrc"
        else
            cfg="$HOME/.vimrc"
        fi
        ;;
    *)
        echo "Choose vim or nvim as argument."
        usage
        ;;
esac

install
