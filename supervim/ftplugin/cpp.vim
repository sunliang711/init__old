function! Main()
    if has('nvim')
        0r ~/.config/nvim/ftplugin/template/template.cpp
    else
        0r ~/.vim/ftplugin/template/template.cpp
    endif
endfunction

command! Main call Main()

