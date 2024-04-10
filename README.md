# vim-blink
Vim plugin manager for blinkshell

Add the following to `~/Documents/.vimrc` to install:
```
if empty(glob(data_dir . '/autoload/blink.vim'))
    call mkdir(expand(data_dir."/autoload"),"p")
    silent execute '!curl -fLo ' . data_dir . '/autoload/blink.vim --create-dirs  https://raw.githubusercontent.com/rrgeorge/vim-blink/master/blink.vim'
endif
call blink#init()
```

You can add `BlinkInstall` to install a plugins, like:
BlinkInstall 'vim-airline/vim-airline'

Add them to your .vimrc if you want to automatically install them at startup
