vim9script

# XXX: handle b:undo

import autoload 'dir.vim'
import autoload 'dir/action.vim'


nnoremap <buffer> <bs> <scriptcmd>action.DoUp()<cr>
nnoremap <buffer> u <scriptcmd>action.DoUp()<cr>
nnoremap <buffer> <cr> <scriptcmd>action.Do()<cr>
nnoremap <buffer> o <scriptcmd>action.Do()<cr>
nnoremap <buffer> O <scriptcmd>action.DoOS()<cr>
nnoremap <buffer> S <scriptcmd>action.Do("split")<cr>
nnoremap <buffer> s <scriptcmd>action.Do("vert split")<cr>
nnoremap <buffer> t <scriptcmd>action.Do("tabe")<cr>
nnoremap <buffer> i <scriptcmd>action.DoPreview()<cr>

nnoremap <buffer> C <scriptcmd>action.DoCopy()<cr>
nnoremap <buffer> cc <scriptcmd>action.DoCopy()<cr>
nnoremap <buffer> D <scriptcmd>action.DoDelete()<cr>
nnoremap <buffer> dd <scriptcmd>action.DoDelete()<cr>
nnoremap <buffer> P <scriptcmd>action.DoPaste()<cr>
nnoremap <buffer> R <scriptcmd>action.DoRename()<cr>
noremap <buffer> r <nop>
xnoremap <buffer> r <nop>
noremap <buffer> d <nop>
xnoremap <buffer> d <nop>
noremap <buffer> c <nop>
xnoremap <buffer> c <nop>
noremap <buffer> p <nop>
xnoremap <buffer> p <nop>

augroup dirautocommands | au!
    au BufReadCmd dir://* dir.Open()
    # au TextYankPost dir://* action.DoYank(v:event)
augroup END
