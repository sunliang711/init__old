"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"basic settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
syntax on
set laststatus=2
set incsearch
set hlsearch
set relativenumber
set cursorline
" set cursorcolumn

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
set autochdir
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
endif

"移动窗口指令
noremap <silent> <C-h> <C-W>h
inoremap <silent> <C-h> <esc><C-W>h
noremap <silent> <C-l> <C-W>l
inoremap <silent> <C-l> <esc><C-W>l
noremap <silent> <C-j> <C-W>j
inoremap <silent> <C-j> <esc><C-W>j
" noremap <silent> <C-k> <C-W>k
" inoremap <silent> <C-k> <esc><C-W>k

"save as root
"cmap w!! w !sudo tee>/dev/null %

"设置gf指令的寻找路径
set path =.,~/.local/include,/usr/local/include,/usr/include,,

"设置空白字符的视觉效果提示
set list listchars=extends:❯,precedes:❮,tab:▸\ ,trail:˽
" set list listchars=extends:❯,precedes:❮,tab:▸\ ,trail:˽,eol:$

"这条指令放到这里可以,放到前面的话会导致windows下的gui的airline箭头显示不了,或者直接注释掉
"scriptencoding utf-8

"vim-plug
"{{{
if has('nvim')
    call plug#begin('~/.config/nvim/plugins')
else
    call plug#begin('~/.vim/plugins')
endif



Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle'  }

Plug 'ctrlpvim/ctrlp.vim'

"状态栏
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"括号补全
Plug 'jiangmiao/auto-pairs'

"自动补全xml html标签
Plug 'docunext/closetag.vim'
"始终高亮包含当前光标位置的html标签,need python support
" Plug 'Valloric/MatchTagAlways'

"切换主题插件
Plug 'chxuan/change-colorscheme'
"注释插件
"快捷键gc（visual模式下）gcc(Normal 模式下)
Plug 'tpope/vim-commentary'
"起始页插件
Plug 'mhinz/vim-startify'
"同时高亮所有的匹配单词
Plug 'haya14busa/incsearch.vim'
"对齐插件 :Tab /<char-to-be-alignment>
Plug 'godlygeek/tabular'
"头文件源文件切换插件
" Plug 'vim-scripts/a.vim'

"快速给词加环绕符号,例如单引号 双引号括号
"常用命令
"替换命令: cs<old-char><new-char>  cst<new-char>  t表示html标签(tag)
"删除命令: ds<deleted-char>
"添加命令: csw<new-char>    w表示write
"添加整行: yss<new-char>
Plug 'tpope/vim-surround'
"使用surround操作之后，使用.号重复操作
Plug 'tpope/vim-repeat'

"自动添加结尾 比如有些语言输入if，会自动添加endif
Plug 'tpope/vim-endwise'

"文档生成工具
"常用命令: :Dox自动生成函数说明  :DoxAuthor自动生成文件说明
Plug 'vim-scripts/DoxygenToolkit.vim'

"vim-go
" Plug 'fatih/vim-go'
"better document viewer
Plug 'garyburd/go-explorer'

if has('nvim')
    Plug 'Shougo/deoplete.nvim'
    Plug 'zchee/deoplete-go'
else
    Plug 'Shougo/neocomplete.vim'
endif

if v:version > 704
    " Plug 'Valloric/YouCompleteMe'
endif

" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'

"给其他插件比如ctrlp nerdtree startify增加图标
Plug 'ryanoasis/vim-devicons'

Plug 'majutsushi/tagbar'

"Usage
":DirDiff <dir1> <dir2>
Plug 'will133/vim-dirdiff'

call plug#end()
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"         CtrlP
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map = '<c-p>'
let g:ctrlp_working_path_mode = 'ra'
if has("win32")
    set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe
    let g:ctrop_user_command='dir %s /-n /b /s /a-d'
else
    "MacOS/Linux
    set wildignore+=*/tmp/*,*.so,*.swp,*.zip
    let g:ctrop_user_command='find %s -type f'
endif

"Usage:
"Press <F5> to purge the cache for the current directory to get new files, remove deleted files and apply new ignore options.
"Press <c-f> and <c-b> to cycle between modes.
"Press <c-d> to switch to filename only search instead of full path.
"Press <c-r> to switch to regexp mode.
"Use <c-j>, <c-k> or the arrow keys to navigate the result list.
"Use <c-t> or <c-v>, <c-x> to open the selected entry in a new tab or in a new split.
"Use <c-n>, <c-p> to select the next/previous string in the prompt's history.
"Use <c-y> to create a new file and its parent directories.
"Use <c-z> to mark/unmark multiple files and <c-o> to open them.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"         Vim-airline
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"the fonts airline used is here ->  https://github.com/powerline/fonts
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
" let g:airline_theme="luna" 
let g:airline_detect_modified=1
let g:airline_detect_paste=1

let g:airline#extensions#default#layout = [
            \ [ 'a', 'b', 'c' ],
            \ [ 'x', 'y', 'z' ]
            \ ]
"下面的分隔符在这里: https://github.com/ryanoasis/nerd-fonts
"每个符号都有对应的unicode code point(四位十六进制数字)
"在vim中打出它们的方式是:在插入模式下按ctrl+v u 十六进制数字
" let g:airline_left_sep = ''
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
" let g:airline_right_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols = {}
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.maxlinenr = '☰'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = '∄'
let g:airline_symbols.whitespace = 'Ξ'

"除了section_b之外，默认都有设置，而且设置的也都蛮好用的
"就不改它们了，这里在section_b处显示当前时间
let g:airline_section_b = '  %{strftime("%m/%d")}  %{strftime("%H:%M")}   0X%B'
" if os ==? "Darwin"
"     let g:airline_section_b = '📅  %{strftime("%m/%d")} ⏰ %{strftime("%H:%M")}   0X%B'
" else
"     let g:airline_section_b = '  %{strftime("%m/%d")}  %{strftime("%H:%M")}   0X%B'
" endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"以下的设置可以测试出section a,b,c,gutter,x,y,z在statusline中的具体位置
" let g:airline_section_a = 'section a'
" let g:airline_section_b = 'section b'
" let g:airline_section_c = 'section c'
" let g:airline_section_gutter = 'section gutter'
" let g:airline_section_x = 'section x'
" let g:airline_section_y = 'section y'
" let g:airline_section_z = 'section z'
" let g:airline_section_error = 'section error'
" let g:airline_section_warning = 'section warning'
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"       incsearch.vim config
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"       DoxyGenToolKit Config
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:DoxygenToolkit_briefTag_pre="@brief  "
let g:DoxygenToolkit_paramTag_pre="@param "
let g:DoxygenToolkit_returnTag="@returns   "
let g:DoxygenToolkit_blockHeader="--------------------------------------------------------------------------"
let g:DoxygenToolkit_blockFooter="--------------------------------------------------------------------------"
let g:DoxygenToolkit_authorName="孙亮 email:sunliang711@gmail.com"
let g:DoxygenToolkit_licenseTag="GPL 2.0"

let s:licenseTag = "Copyright(C)\<enter>"
let s:licenseTag = s:licenseTag . "For free\<enter>"
let s:licenseTag = s:licenseTag . "All right reserved\<enter>"
let g:DoxygenToolkit_licenseTag = s:licenseTag
let g:DoxygenToolkit_briefTag_funcName="yes"
let g:doxygen_enhanced_color=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"      YouCompleteMe Config
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:ycm_global_ycm_extra_conf='~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
if has('nvim')
    let g:ycm_global_ycm_extra_conf='~/.config/nvim/plugins/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
else
    let g:ycm_global_ycm_extra_conf='~/.vim/plugins/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
endif
let g:ycm_confirm_extra_conf = 0
let g:ycm_error_symbol = '>>'
let g:ycm_warning_symbol = '>*'
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1

" let g:ycm_key_list_select_completion = ['', '']
" let g:ycm_key_list_previous_completion = ['']
" let g:ycm_key_invoke_completion = '<C-Space>'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"         ultisnips
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" UltiSnips setting
" let g:UltiSnipsExpandTrigger="<c-k>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"      Nerdtree Config
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle NerdTree
nnoremap <silent> <F2> :NERDTreeToggle<CR>

nnoremap <F8> :TagbarToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"      vim-go
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

" let g:go_fmt_fail_silently = 1
" au FileType go map <F3> <Plug>(go-def-vertical)
au FileType go map <F3> <Plug>(go-def)
au FileType go map <F4> <Plug>(go-doc)
au FileType go map <F5> <Plug>(go-run)

"
if has('nvim')
    color github
else
    color summerfruit256
endif

map <f3> :execute "noautocmd vimgrep /" .expand("<cword>") . "/gj " . expand("%") <Bar>cw<CR>
map <f4> :execute "noautocmd vimgrep /" . expand("<cword>") . "/gj **" <Bar>  cw<CR>

nnoremap <silent> <F9> :PreviousColorScheme<CR>
nnoremap <silent> <F10> :NextColorScheme<CR>

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
