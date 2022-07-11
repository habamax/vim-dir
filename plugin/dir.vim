vim9script

if exists('g:loaded_dir')
    finish
endif
g:loaded_dir = 1

import autoload 'dir.vim'

command! -nargs=? -complete=dir Dir dir.Open(<f-args>)
