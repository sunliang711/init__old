"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"basic settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
syntax on
set laststatus=2
set incsearch
set hlsearch
if v:version >= 704
    set number relativenumber
    augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
        autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
    augroup END
else
    set relativenumber
endif

set cursorline
set cursorcolumn

"set mouse=c
set mouse=a
"如果用ssh的连接工具，比如putty xshell连接远程服务器
"打开vim的话，它的t_Co会设置成8，这样airline的状态栏
"就不会有五颜六色了，所以这里设置成256来让airline正
"确的显示颜色
set t_Co=256
set wrap
set confirm
set shiftwidth=4
set tabstop=4
set expandtab
set smarttab
set backspace=indent,eol,start whichwrap+=<,>,[,]
" set patchmode=.orig
let mapleader=','
set termencoding=utf8
set encoding=utf8
set fileencodings=utf8,ucs-bom,gbk,cp936,gb2312,gb18030
"允许在未保存时切换buffer
set hidden
set showcmd
" set autochdir

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

set clipboard=unnamed
nnoremap j gj
nnoremap k gk


let os = substitute(system("uname"),"\n","","")
if os ==? "Darwin"
    "光标形状,否则在iterm2中显示的不容易看清
    " let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    " let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    "for macvim
    "这个字体要首先安装，官方地址：https://github.com/powerline/fonts
    "用git clone下载之后，执行里面的install.sh
    "TODO modify the font of macvim
    set guifont=Anonymous\ Pro\ for\ Powerline:h16
endif

if has("win32")
    set guifont=DroidSansMonoForPowerline_NF:h12:cANSI:qDRAFT
    set guioptions-=m
    set guioptions-=T
    set guioptions-=l
    set guioptions-=L
    set guioptions-=r
    set guioptions-=R
    set guioptions-=b
endif
" " linux gvim setting
" if has("unix") && has("gui_running")
"     set guifont=DroidSansMonoForPowerline\ Nerd\ Font\ 10
" endif
" gvim setting
if has("gui_running")
    if has("gui_macvim")
        set guifont=HackNerdFontComplete-Regular:h14
    elseif has("gui_gtk2") || has("gui_gtk3")
        set guifont=DroidSansMonoForPowerline\ Nerd\ Font\ 10
    elseif has("gui_win32")
        "Win32/64 GVim
    endif
endif

if has("gui_running")
    set lines=50
    set columns=100
endif

hi PmenuSel guifg=#dddddd guibg=#5978f2 ctermfg=black ctermbg=yellow

augroup LastPosition
    au!
    autocmd BufReadPost *
                \ if line("'\"") > 1 && line("'\"") <= line("$")|
                \ execute "normal! g`\""|
                \ endif

augroup END

if has('nvim')
    "真彩色显示
    let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
    "允许光标变化
    "has bug
    " let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
    nnoremap <silent> <leader>e :tab e ~/.config/nvim/init.vim<CR>
    nnoremap <silent> <leader>c :tab e ~/.config/nvim/basic.vim<CR>
else
    " when vim version is 7.4, v:version is 704
    if v:version >= 704
        if filereadable(expand('~/.vim/vimrc'))
            nnoremap <silent> <leader>e :tab e ~/.vim/vimrc<CR>
        else
            nnoremap <silent> <leader>e :tab e ~/.vimrc<CR>
        endif
    else
        nnoremap <silent> <leader>e :tab e ~/.vimrc<CR>
    endif
    nnoremap <silent> <leader>c :tab e ~/.vim/basic.vim<CR>
endif

"移动窗口指令
" noremap <silent> <C-h> <C-W>h
" inoremap <silent> <C-h> <esc><C-W>h
" noremap <silent> <C-l> <C-W>l
" inoremap <silent> <C-l> <esc><C-W>l
" noremap <silent> <C-j> <C-W>j
" inoremap <silent> <C-j> <esc><C-W>j
" noremap <silent> <C-k> <C-W>k
" inoremap <silent> <C-k> <esc><C-W>k

nnoremap <leader>U gUiw
nnoremap <leader>u guiw

"save as root
"cmap w!! w !sudo tee>/dev/null %

"设置gf指令的寻找路径
set path =.,~/.local/include,/usr/local/include,/usr/include,,

"设置空白字符的视觉效果提示
set list listchars=extends:❯,precedes:❮,tab:▸\ ,trail:˽
" set list listchars=extends:❯,precedes:❮,tab:▸\ ,trail:˽,eol:$

"这条指令放到这里可以,放到前面的话会导致windows下的gui的airline箭头显示不了,或者直接注释掉
"scriptencoding utf-8
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"      format json file
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
":%!python -m json.tool
command! JsonFormat :%!python -m json.tool

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"      write with root privilege
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! W :execute ':silent w !sudo tee % > /dev/null' | :edit!
command! Wq :execute ':silent w !sudo tee % > /dev/null' | :edit! | :quit

" search in current file
nnoremap <F3> :execute "noautocmd vimgrep /" .expand("<cword>") . "/gj " . expand("%") <Bar>cw<CR>
" search in current directory and all subdirectories
nnoremap <F4> :execute "noautocmd vimgrep /" . expand("<cword>") . "/gj **" <Bar>  cw<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"      terminal escape
"      如果喜欢在终端中启用vi模式的话，不要用下面的esc来映射<C-\><C-n>
"      <C-\><C-n>这个组合键是用来逃离vim中的终端，这样可以跳转到其它的vim窗口
"      如果用esc来映射这组快捷键的话，那么就进入不了终端的vi模式了，也就用不了j、k这些查看历史命令的
"      快捷键了。
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tnoremap <Esc> <C-\><C-n>
tnoremap <leader>c <C-\><C-n>

set splitbelow
set splitright

" 执行完<leader>b后可以输入buffer
" 数字编号或者buffer名字来切换到buffer，或者使用tab来循环补全
" <leader>b快键键已被Leaderf buffer占用，那个比这个好
" nnoremap <leader>b :buffers<CR>:buffer<Space>
nnoremap <F5> :bel terminal<CR>

"在jump list中跳转
"输入普通数字表示向后跳转(<C-O>),数字之前加个'+'表示向前跳转(<C-I>)
nnoremap <leader>j :call GotoJump()<CR>
function! GotoJump()
  jumps
  let j = input("Please select your jump: ")
  if j != ''
    let pattern = '\v\c^\+'
    if j =~ pattern
      let j = substitute(j, pattern, '', 'g')
      execute "normal " . j . "\<c-i>"
    else
      execute "normal " . j . "\<c-o>"
    endif
  endif
endfunction

"vim-plug
"{{{
if has('nvim')
    call plug#begin('~/.config/nvim/plugins')
else
    call plug#begin('~/.vim/plugins')
endif

