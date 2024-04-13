# vim-blink
Vim plugin manager for blinkshell. 
Most vim plugin managers depend on the `git` cli, which is not available on blink. This plugin manager uses `curl` to download and install plugins from GitHub instead of `git`. 

Add the following to `~/Documents/.vimrc` to install:
```vim
let data_dir = expand('~/Documents/.vim')
if empty(glob(data_dir . '/autoload/blink.vim'))
    call mkdir(expand(data_dir."/autoload"),"p")
    silent execute '!curl -fLo ' . data_dir . '/autoload/blink.vim --create-dirs  https://raw.githubusercontent.com/rrgeorge/vim-blink/master/blink.vim'
endif
call blink#init()
```

You can add `Blink` to activate plugins (and install as needed), like:
Blink 'vim-airline/vim-airline'

To simply install without activatinging, you can use `BlinkInstall`, like:
BlinkInstall 'vim-airline/vim-airline'

To check all plugins for updates, run `:BlinkUpdate`

## My vimrc
This is the `~/Documents/.vimrc` I am using on my devices. You can download it directly if you like, by running:
`curl -fLo ~/Documents/.vimrc https://raw.githubusercontent.com/rrgeorge/vim-blink/master/vimrc`  

The contents:
```vim
set termguicolors   " enables colors
set encoding=utf8
set background=dark
set backspace=2
syntax on

let data_dir = expand('~/Documents/.vim')
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

```
