vim9script

if exists("b:did_ftplugin")
    finish
endif
b:did_ftplugin = 1

var undo_opts = "setl spell<"

setlocal nospell


var nop_maps = ['r', 'd', 'c', 'C', 'p', 'gp', 'a', 'I', 'gI', 'gi', 'U', '<C-r>']
var undo_maps = ['<bs>', '\<cr>', 'u', 'o', 'O', 'S', 's', 'A',
                 't', 'i', 'x', 'X', 'D', 'dd', 'R', 'rr', 'P', 'gP']

b:undo_ftplugin = undo_opts .. ' | '
b:undo_ftplugin ..= (nop_maps + undo_maps)->mapnew((_, v) => $'exe "unmap <buffer> {v}"')->join(' | ')
b:undo_ftplugin ..= ' | unlet b:dir | unlet b:dir_cwd'


import autoload 'dir.vim'
import autoload 'dir/action.vim'

nnoremap <buffer> <bs> <scriptcmd>action.DoUp()<cr>
nnoremap <buffer> u <scriptcmd>action.DoUp()<cr>
xnoremap <buffer> u <scriptcmd>action.DoUp()<cr>
nnoremap <buffer> <cr> <scriptcmd>action.Do()<cr>
nnoremap <buffer> o <scriptcmd>action.Do()<cr>
nnoremap <buffer> O <scriptcmd>action.DoOS()<cr>
nnoremap <buffer> S <scriptcmd>action.Do($"{g:dir_invert_split ? '' : 'vert'} split")<cr>
xnoremap <buffer> S <nop>
nnoremap <buffer> s <scriptcmd>action.Do($"{g:dir_invert_split ? 'vert' : ''} split")<cr>
xnoremap <buffer> s <nop>
nnoremap <buffer> t <scriptcmd>action.Do("tabe")<cr>
nnoremap <buffer> i <scriptcmd>action.DoInfo()<cr>


noremap <buffer> x <scriptcmd>action.DoMark()<cr>j
xnoremap <buffer> x <scriptcmd>action.DoMark()<cr><ESC>j
noremap <buffer> X <scriptcmd>action.DoClearMarks()<cr>
xnoremap <buffer> X <scriptcmd>action.DoClearMarks()<cr>
noremap <buffer> D <scriptcmd>action.DoDelete()<cr>
xnoremap <buffer> D <scriptcmd>action.DoDelete()<cr>
noremap <buffer> dd <scriptcmd>action.DoDelete()<cr>
xnoremap <buffer> dd <scriptcmd>action.DoDelete()<cr>
noremap <buffer> P <scriptcmd>action.DoCopy()<cr>
xnoremap <buffer> P <scriptcmd>action.DoCopy()<cr>
noremap <buffer> gP <scriptcmd>action.DoMove()<cr>
xnoremap <buffer> gP <scriptcmd>action.DoMove()<cr>
noremap <buffer> R <scriptcmd>action.DoRename()<cr>
xnoremap <buffer> R <scriptcmd>action.DoRename()<cr>
noremap <buffer> rr <scriptcmd>action.DoRename()<cr>
xnoremap <buffer> rr <scriptcmd>action.DoRename()<cr>
nnoremap <buffer> A <scriptcmd>action.DoAction()<cr>
xnoremap <buffer> A <scriptcmd>action.DoAction()<cr>


# remove buffer editing mappings
for key in nop_maps
    exe $'noremap <buffer> {key} <nop>'
    exe $'xnoremap <buffer> {key} <nop>'
endfor


augroup dirautocommands | au!
    au BufReadCmd dir://* dir.Open()
augroup END
