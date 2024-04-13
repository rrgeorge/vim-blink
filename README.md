# vim-blink
Vim plugin manager for blinkshell. 
Most vim plugin managers depend on the `git` cli, which is not available on blink. This plugin manager uses `curl` to download and install plugins from GitHub instead of `git`. 

Add the following to `~/Documents/.vimrc` to install:
```
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
