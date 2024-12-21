" ===================================
" Options
" ===================================

set encoding=UTF-8
set spelllang=en_us,pt_br
set number " Enable line numbers
set mouse=a " Enable mouse
set breakindent " Enable break indent
set signcolumn=yes " Keep signcolumn on by default
set updatetime=1000 " Decreate update time
set timeoutlen=500 " Time to wait for a mapped sequence to complete (in milliseconds). Reduce it later
set ttimeoutlen=10 " Time to wait for  a terminal key sequence (like Esc) to complete
set undofile " Save undo history
set undodir=~/.vim/undodir
set nobackup " Don't create a backup file 
set nowritebackup " Don't write backup before overwriting
set completeopt=menuone,preview,fuzzy " Better completion experience
set whichwrap+=<,>,[,],h,l " Allow certain keys to move to the next line
set nowrap " Display long lines as one line
set linebreak "Don't break words when wrapping
set scrolloff=4 " Amount of lines to keep above/below cursor
set sidescrolloff=8 " Amount of columns to the left/right of cursor
set relativenumber " Use relative line numbers
set numberwidth=4 " Number of column width
set shiftwidth=4 " Spaces per indentation
set tabstop=4 " Spaces per tab
set softtabstop=4 " Spaces per tab during editing ops
set expandtab " Convert tabs to spaces
set nocursorline " Don't highlight the current line
set splitbelow " Horizontal splits below current window
set splitright " Vertial splits to the right
set noswapfile " Don't use a swap file
set smartindent " Smart indentation
set showtabline=2 " Always show tab line
set backspace=indent,eol,start " Configurable backspace behavior
set pumheight=10 " Popup menu height
set conceallevel=0 " Make `` visible in markdown
set fileencoding=utf-8 " File encoding
set cmdheight=1 " Command line height
set autoindent " Auto-indent new lines
" set shortmess+=c " Don't show completion menu message
" set iskeyword+=- " Treat hephenated words as whole words
set showmatch " Show the matching part of pairs [] {}  and ()

"================================
" Search
" ===============================
set hlsearch " Enable highlighting search results
set incsearch " Show search results as you type
set ignorecase " Case-insensitive searching unless \C or capital in search
set smartcase " Enable smart case

" ================================
" Status line
" ================================

set laststatus=2 " Show status bar
set statusline=%f " Path of the file
set statusline+=%= " Switch to the right side
set statusline+=%l " Current line
set statusline+=/ " Separator
set statusline +=%L " Total lines

" ====================================
" Keymaps
" ====================================

" Set leader key
let mapleader = " "
let maplocalLeader = " "


" Disable the spacebar key's default behavior in Normal and Visual modes
nnoremap <Space> <Nop>
vnoremap <Space> <Nop>

" Allow moving the cursor through wrapped lines with j, k
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'

" clear highlights
nnoremap <Esc> :noh<CR>

" Save file
nnoremap <C-s> :w<CR>

" Quit file
nnoremap <C-q> :q<CR>

" Delete single character without copying into register
" and also allowing to delete two characters without to
" have to press x three times
nnoremap <expr> x v:count == 0 ? '"_x' : '"_d'.v:count.'1'

" Resize with arrows

" nnoremap <Up> :resize -2<CR>
" nnoremap <S-Tab> :bprevious<CR>
" nnoremap <Left> :vertial resize -2<CR>
" nnoremap <Right> :vertial resize +2<CR>

 
" Navigate between splits
nnoremap <C-k> :wincmd k<CR>
nnoremap <C-j> :wincmd j<CR>
nnoremap <C-h> :wincmd h<CR>
nnoremap <C-l> :wincmd l<CR>

" Tabs
nnoremap <leader>to :tabnew<CR>
nnoremap <leader>tx :tabclose<CR>
nnoremap <leader>tn :tabn<CR>
nnoremap <leader>tp :tabp<CR>

" Toggle line wrapping
nnoremap <leader>lw :set wrap!<CR>

" Explicitly yank to system clpiboard (highlighted and entiry row)
noremap <leader>y "+y
noremap <leader>Y "+Y

" Open file explorer
noremap <silent> <leader>e :Lex<CR>

noremap <S-CR> o 

" =================================
" Other
" =================================

" Syntax highlighting
syntax on




" Colorscheme
" Coloschema industry
colorscheme wildcharm
set background=dark

" Sync clipboard with OS

if system('uname -s') == "Darwin\n"
    set clipboard=unnamed " OSX
else
    set clipboard=unnamedplus  " Linux
endif

" True colors
if !has('gui_running') && &term =~ '\%(screen\|tmux\)'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors

" =================================
" Cursor
" =================================

" Change cursor shape in different modes
if exists('$TERM')
    " Insert mode: Underscore cursor
    let &t_SI = "\e[4 q"
    " Normal mode:  Block cursor
    let &t_EI = "\e[2 q"
    " Replace mode: Slim vertical line cursor
    let &t_SR = "\e[1 q"
endif

