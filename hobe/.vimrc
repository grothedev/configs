set tabstop=4
set shiftwidth=4
set expandtab
set t_Co=256

set termguicolors
set background=dark
set ignorecase
set smartcase

syntax enable

let mapleader = " "

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <leader>% :vsplit<CR>
nnoremap <leader>" :split<CR>
nnoremap <leader>t :tabnew<CR>
nnoremap <leader>f :Ex<CR>
nnoremap <leader>b :bd<CR>

set number
"set relativenumber
set autoindent
set smartindent
set incsearch
set hlsearch
set wrap
set linebreak
set showmatch
set wildmenu
set laststatus=2
set ruler
set showcmd
set backspace=indent,eol,start

" Enable syntax highlighting
syntax on
filetype plugin indent on

" vim-plug plugin manager
call plug#begin('~/.vim/plugged')

"" Essential plugins
"Plug 'tpope/vim-sensible'          " Sensible defaults
"Plug 'tpope/vim-commentary'        " Easy commenting with gc
"Plug 'tpope/vim-surround'          " Surround text with quotes/brackets
"Plug 'tpope/vim-repeat'            " Repeat plugin actions with .
"
"" File navigation
"Plug 'preservim/nerdtree'          " File tree
Plug 'ctrlpvim/ctrlp.vim'          " Fuzzy file finder
"
"" Status line
"Plug 'vim-airline/vim-airline'     " Better status line
"Plug 'vim-airline/vim-airline-themes'
"
"" Syntax highlighting
Plug 'sheerun/vim-polyglot'        " Language pack
"
"" Git integration
"Plug 'tpope/vim-fugitive'          " Git wrapper
"
"" Color scheme
Plug 'morhetz/gruvbox'             " Popular color scheme
"
call plug#end()

" Plugin configurations
" NERDTree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

" CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'

" Airline
"let g:airline_powerline_fonts = 1
"let g:airline_theme = 'gruvbox'

" Color scheme
colorscheme gruvbox
"set background=dark

" Key mappings
"let mapleader = " "

nnoremap <leader>x :x<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Toggle paste mode
nnoremap <leader>p :set paste!<CR>

set tags=./tags;,tags
