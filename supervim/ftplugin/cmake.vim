function! Main()
    if has('nvim')
        0r ~/.config/nvim/ftplugin/template/template.cmake
    else
        0r ~/.vim/ftplugin/template/template.cmake
    endif
endfunction

command! Main call Main()
