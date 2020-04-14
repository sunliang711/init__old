
fzfp() {
    fzf --bind 'ctrl-f:preview-page-down' --bind 'ctrl-b:preview-page-up' --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || rougify {}  || highlight -O ansi -l {} || coderay {} || cat {}) 2> /dev/null | head -500'
}

fzfe(){
    if ! command -v fd >/dev/null 2>&1;then
        echo "Command not found: 'fd'"
        return 1
    fi
    local dest=${1:-.}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    editor=vi
    if command -v vim >/dev/null 2>&1;then
        editor=vim
    fi

    if command -v nvim >/dev/null 2>&1;then
        editor=nvim
    fi

    #TODO multiple file
    file=$(fd --type f | fzf --border --height 60% --reverse -m --bind 'ctrl-f:preview-page-down' --bind 'ctrl-b:preview-page-up' --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || rougify {}  || highlight -O ansi -l {} || coderay {} || cat {}) 2> /dev/null | head -500')
    if [ -n "$file" ];then
        $editor $file
    fi
    cd "$wd"
}

fzfE(){
    if ! command -v fd >/dev/null 2>&1;then
        echo "Command not found: 'fd'"
        return 1
    fi
    local dest=${1:-.}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    editor=vi
    if command -v vim >/dev/null 2>&1;then
        editor=vim
    fi

    if command -v nvim >/dev/null 2>&1;then
        editor=nvim
    fi

    #TODO multiple file
    file=$(fd -HI --type f | fzf --border --height 60% --reverse -m --bind 'ctrl-f:preview-page-down' --bind 'ctrl-b:preview-page-up' --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || rougify {}  || highlight -O ansi -l {} || coderay {} || cat {}) 2> /dev/null | head -500')
    if [ -n "$file" ];then
        $editor $file
    fi
    cd "$wd"
}
fzfcd(){
    if ! command -v fd >/dev/null 2>&1;then
        echo "Command not found: 'fd'"
        return 1
    fi

    local dest=${1:-.}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    local dir
    dir=$(fd --type d | fzf --height 60% --border --reverse) && cd "$dir" || { echo "Canceled"; cd "$wd"; }
}

fzfCD(){
    if ! command -v fd >/dev/null 2>&1;then
        echo "Command not found: 'fd'"
        return 1
    fi

    local dest=${1:-.}
    if [ -d "$dest" ];then
        local wd=$(pwd)
        cd "$dest"
    else
        echo "No such directory: '$dest'"
        return 1
    fi

    local  dir
    dir=$(fd -HI --type d | fzf --height 80% --border --reverse) && cd "$dir" || { echo "Canceled"; cd "$wd"; }
}
