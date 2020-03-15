#!/usr/bin/env bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
thisDir="$(cd $(dirname $rpath) && pwd)"
cd "$thisDir"

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
            https://gitee.com/quick-source/vim-plug/raw/master/plug.vim || { echo "download vim-plug failed.";uninstall; exit 1; }
        #use gitee.com repo (in China!!)
        # sed -ibak -e 's|github.com/junegunn|gitee.com/quick-source|g' -e 's|github\.com|gitee.com|g'  -e 's|github\\\.com|gitee\\.com|g' $root/autoload/plug.vim
    fi


    ## fill plugins to vimrc(init.vim)
    # source ./allPlugins.sh || { echo "load allPlugins.sh error"; exit 1; }

    ### header
    cat ./header.vim > $cfg

    ### display menu for user to choose which plugins to be installed
    pluginsDir="plugins-available"
    echo "Available plugins are in ${pluginsDir}"
    userChoiceFile="/tmp/vim-plugin-install-menu"
    echo "## Set plugin name to 1 to install it." > ${userChoiceFile}
    cd ${pluginsDir}
    for plugin in *.plugin;do
        echo "Debug: plugin: ${plugin}"
        #1. get plugin name
        pluginName=`perl -ne 'print $1 if /^\s*NAME\s*:\s*"([^"]+)"\s*$/' ${plugin}`
        echo "Debug: pluginName: ${pluginName}"
        #2. get default
        pluginDefault=`perl -ne 'print $1 if /^\s*DEFAULT\s*:\s*(.+)$/' ${plugin}`
        echo "Debug: pluginDefault: ${pluginDefault}"

        printf "%-25s = %s\n" ${pluginName} ${pluginDefault} >> ${userChoiceFile}
    done

    $VIM ${userChoiceFile}

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
    done < ${userChoiceFile}
    rm ${userChoiceFile}

    echo "Debug: toBeInstalledPlugins: ${toBeInstalledPlugins}"

    for plugin in *.plugin;do
        echo "Debug: plugin: ${plugin}"
        #1. get plugin name
        pluginName=`perl -ne 'print $1 if /^\s*NAME\s*:\s*"([^"]+)"\s*$/' ${plugin}`
        echo "Debug: pluginName: ${pluginName}"
        if ! printf "%s\n" ${toBeInstalledPlugins[@]} | grep -q "$pluginName";then
            #skip
            continue
        fi
        #2. get plugin path
        pluginPath=`perl -ne 'print if /PATH BEGIN/.../PATH END/' ${plugin} | sed -e '1d;$d'`
        echo "Debug: pluginPath: ${pluginPath}"
        if (($origin==1));then
            echo "$pluginPath" >> $cfg
        else
            echo "$pluginPath" | perl -pe "s|(Plug ')[^/]+(/.+)|\1https://gitee.com/quick-source\2|" >> "$cfg"
        fi
    done

    echo  >> "$cfg"
    echo "call plug#end()" >> "$cfg"

    echo  >> "$cfg"

    ## CONFIG
    for plugin in *.plugin;do
        echo "Debug: plugin: ${plugin}"
        #1. get plugin name
        pluginName=`perl -ne 'print $1 if /^\s*NAME\s*:\s*"([^"]+)"\s*$/' ${plugin}`
        echo "Debug: pluginName: ${pluginName}"
        if ! printf "%s\n" ${toBeInstalledPlugins[@]} | grep -q "$pluginName";then
            #skip
            continue
        fi
        #2. get plugin config
        perl -ne 'print if /CONFIG BEGIN/.../CONFIG END/' ${plugin} |sed -e '1d;$d' >> "$cfg"
    done



    echo "Install plugin..."
    $VIM -c PlugInstall -c qall

    # export VIM,root,thisDir for script use
    export VIM
    export root
    export thisDir

    ## SCRIPT
    echo "RUN scripts."
    for plugin in *.plugin;do
        echo "Debug: plugin: ${plugin}"
        #1. get plugin name
        pluginName=`perl -ne 'print $1 if /^\s*NAME\s*:\s*"([^"]+)"\s*$/' ${plugin}`
        echo "Debug: pluginName: ${pluginName}"
        if ! printf "%s\n" ${toBeInstalledPlugins[@]} | grep -q "$pluginName";then
            continue
        fi
        #2. get plugin script
        perl -ne 'print if /SCRIPTS BEGIN/.../SCRIPTS END/' ${plugin} |sed -e '1d;$d' > /tmp/${pluginName}.sh
        if [ -f /tmp/${pluginName}.sh ];then
            echo "Run /tmp/${pluginName}.sh"
            bash /tmp/${pluginName}.sh
            /bin/rm -rf /tmp/${pluginName}.sh
        fi
    done
    ## restore PWD
    cd ${thisDir}

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
           echo "Unknown option: '$OPTARG'"
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
