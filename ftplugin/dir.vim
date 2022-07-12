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

noremap <buffer> C <scriptcmd>action.DoCopy()<cr>
xnoremap <buffer> C <scriptcmd>action.DoCopy()<cr>
noremap <buffer> cc <scriptcmd>action.DoCopy()<cr>
xnoremap <buffer> cc <scriptcmd>action.DoCopy()<cr>
noremap <buffer> D <scriptcmd>action.DoDelete()<cr>
xnoremap <buffer> D <scriptcmd>action.DoDelete()<cr>
noremap <buffer> dd <scriptcmd>action.DoDelete()<cr>
xnoremap <buffer> dd <scriptcmd>action.DoDelete()<cr>
noremap <buffer> P <scriptcmd>action.DoPaste()<cr>
xnoremap <buffer> P <scriptcmd>action.DoPaste()<cr>
noremap <buffer> gP <scriptcmd>action.DoMove()<cr>
xnoremap <buffer> gP <scriptcmd>action.DoMove()<cr>
noremap <buffer> R <scriptcmd>action.DoRename()<cr>
xnoremap <buffer> R <scriptcmd>action.DoRename()<cr>
noremap <buffer> r <nop>
xnoremap <buffer> r <nop>
noremap <buffer> d <nop>
xnoremap <buffer> d <nop>
noremap <buffer> c <nop>
xnoremap <buffer> c <nop>
noremap <buffer> p <nop>
xnoremap <buffer> p <nop>
noremap <buffer> gp <nop>
xnoremap <buffer> gp <nop>
noremap <buffer> x <nop>
xnoremap <buffer> x <nop>
noremap <buffer> X <nop>
xnoremap <buffer> X <nop>
noremap <buffer> A <nop>
xnoremap <buffer> A <nop>
noremap <buffer> I <nop>
xnoremap <buffer> I <nop>
noremap <buffer> gI <nop>
xnoremap <buffer> gI <nop>
noremap <buffer> gi <nop>
xnoremap <buffer> gi <nop>


augroup dirautocommands | au!
    au BufReadCmd dir://* dir.Open()
    # au TextYankPost dir://* action.DoYank(v:event)
augroup END
