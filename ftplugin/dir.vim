vim9script

# XXX: handle b:undo

import autoload 'dir.vim'
import autoload 'action.vim'


nnoremap <buffer> <bs> <scriptcmd>action.DoUp()<cr>
nnoremap <buffer> <cr> <scriptcmd>action.Do()<cr>
nnoremap <buffer> s <scriptcmd>action.Do("split")<cr>
nnoremap <buffer> v <scriptcmd>action.Do("vert split")<cr>
nnoremap <buffer> t <scriptcmd>action.Do("tabe")<cr>
nnoremap <buffer> i <scriptcmd>action.DoPreview()<cr>


augroup dirautocommands | au!
    au BufReadCmd dir://* dir.Open()
augroup END
