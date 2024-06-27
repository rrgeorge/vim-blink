set termguicolors   " enables colors
set encoding=utf8
set background=dark
set backspace=2
syntax on

let data_dir = expand('~/.vim')
if empty(glob(data_dir . '/autoload/blink.vim'))
    call mkdir(expand(data_dir."/autoload"),"p")
    silent execute '!curl -fLo ' . data_dir . '/autoload/blink.vim --create-dirs  https://raw.githubusercontent.com/rrgeorge/vim-blink/master/blink.vim'
endif

call blink#init()

Blink 'ryanoasis/vim-devicons'
Blink 'vim-airline/vim-airline'
Blink 'vim-airline/vim-airline-themes'
Blink 'fcpg/vim-osc52'
Blink 'preservim/nerdtree'
Blink 'preservim/tagbar'

let g:airline_powerline_fonts = 1
let NERDTreeQuitOnOpen=1

autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | Oscyank " | endif
nnoremap <leader>n :NERDTreeToggle<CR>

