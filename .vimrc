set shell=/bin/zsh
syntax on
set backspace=indent,eol,start      " Make backspace behave like every other editor
packloadall                         " Load packages



"---------- mappings ----------"
" nmap means normal mode mapping
" <cr> means carriage return
" <silent> means show no message
" <C-D> means ctrl+D

let mapleader=','                   " change <Leader> from \ to ,

" Make it easy to edit .vimrc
nmap <Leader>ev :e $MYVIMRC<cr>      

" stop highlighting search results
nmap <Leader><space> :nohlsearch<cr>



"---------- auto commands ----------"
" this prevents repeated sourcing with each save
augroup autosourcing
    autocmd!
    " automatically source .vimrc on save
    autocmd BufWritePost .vimrc source %
augroup END



"------ search ----------"
set hlsearch                        " highlight search results
set incsearch                       " incremental search



"------ split management ----------"
" always create splits below or to the right
set splitbelow
set splitright

" C stands for control
" This is to move between splits more easily

nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-H> <C-W><C-H>
nmap <C-L> <C-W><C-L>



"------ ctrlP ------"
let g:ctrlp_match_window = 'top,order:ttb,min:1,max:20,results:20'

" Make NERDTree easier to toggle
nmap <silent> <C-D> :NERDTreeToggle<cr>



"----- NERDTree -----"
" Don't let NERDTree take - binding from Vinegar
let NERDTreeHijackNetrw = 0



"------ vim-airline ------"
let g:airline_powerline_fonts = 1
let g:airline_theme='desertink'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''



"------ auto-commands ------"
" Automatically source .vimrc on save
augroup autosourcing
    autocmd!
    autocmd BufWritePost .vimrc source %
augroup END



"------ visuals ------"
set number                          " line numbers
colorscheme atom-dark-256
set t_Co=256
set cursorline
set noshowmode
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4

