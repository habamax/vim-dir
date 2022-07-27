vim9script

if exists("b:did_ftplugin")
    finish
endif
b:did_ftplugin = 1

var undo_opts = "setl spell< buftype< bufhidden< buflisted< swapfile<"

setlocal nospell
setlocal buftype=acwrite
setlocal bufhidden=hide
setlocal nobuflisted
setlocal noswapfile


var nop_maps = ['r', 'd', 'c', 'C', 'a', 'I',
                'gp', 'gP', 'gi', 'gI', 'gu', 'gU', 'gh', 'gH',
                'U', '<C-r>', '<C-w>f', '<C-w>F', 'gf', 'gF'
               ]
var undo_maps = ['<bs>', '\<cr>', 'u', 'o', 'O', 'S', 's', 'A', '~', 'g~', 'gb',
                 't', 'i', 'x', 'X', 'D', 'dd', 'R', 'rr', 'p', 'P', ']]', '[[',
                 'g1', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7', 'g8', 'g9', 'g0',
                 '<C-a>1', '<C-a>2', '<C-a>3', '<C-a>4', '<C-a>5',
                 '<C-a>6', '<C-a>7', '<C-a>8', '<C-a>9', '<C-a>0',
                ]

b:undo_ftplugin = undo_opts .. ' | '
b:undo_ftplugin ..= (nop_maps + undo_maps)->mapnew((_, v) => $'exe "unmap <buffer> {v}"')->join(' | ')


import autoload 'dir.vim'
import autoload 'dir/action.vim'


command! -buffer -nargs=? -bang DirFilter action.DoFilter("<bang>", <f-args>)
command! -buffer -nargs=? -bang DirFilterClear action.DoFilterClear()
command! -buffer -nargs=1 -complete=custom,dir#action#BookmarkComplete DirBookmarkJump action.BookmarkJump(<q-args>)
command! -buffer DirBookmark action.BookmarkSet()

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


noremap <buffer> x <scriptcmd>action.DoMarkToggle()<cr>j
xnoremap <buffer> x <scriptcmd>action.DoMarkToggle()<cr><ESC>j
noremap <buffer> X <scriptcmd>action.DoMarksAllToggle()<cr>
xnoremap <buffer> X <scriptcmd>action.DoMarksAllToggle()<cr>
noremap <buffer> D <scriptcmd>action.DoDelete()<cr>
xnoremap <buffer> D <scriptcmd>action.DoDelete()<cr>
noremap <buffer> dd <scriptcmd>action.DoDelete()<cr>
xnoremap <buffer> dd <scriptcmd>action.DoDelete()<cr>
noremap <buffer> p <scriptcmd>action.DoCopy()<cr>
xnoremap <buffer> p <scriptcmd>action.DoCopy()<cr>
noremap <buffer> P <scriptcmd>action.DoMove()<cr>
xnoremap <buffer> P <scriptcmd>action.DoMove()<cr>
noremap <buffer> R <scriptcmd>action.DoRename()<cr>
xnoremap <buffer> R <scriptcmd>action.DoRename()<cr>
noremap <buffer> rr <scriptcmd>action.DoRename()<cr>
xnoremap <buffer> rr <scriptcmd>action.DoRename()<cr>
nnoremap <buffer> A <scriptcmd>action.DoAction()<cr>
xnoremap <buffer> A <scriptcmd>action.DoAction()<cr>
nnoremap <buffer> g, <scriptcmd>action.DoSort("size")<cr>
nnoremap <buffer> g. <scriptcmd>action.DoSort("time")<cr>
nnoremap <buffer> g/ <scriptcmd>action.DoSort("name")<cr>

nnoremap <buffer> . <scriptcmd>action.DoFilterHidden()<cr>

noremap <buffer> ]] <scriptcmd>action.JumpForward()<cr>
noremap <buffer> [[ <scriptcmd>action.JumpBackward()<cr>


nnoremap <buffer> ~ <scriptcmd>Dir ~<cr>
nnoremap <buffer> g~ <scriptcmd>Dir ~<cr>
for idx in range(10)
    exe $'nnoremap <buffer> g{idx} <scriptcmd>action.BookmarkJumpNum({idx})<cr>'
    exe $'nnoremap <buffer> <C-a>{idx} <scriptcmd>action.BookmarkSetNum({idx})<cr>'
endfor

nnoremap <buffer> gb <scriptcmd>action.BookmarkJumpMenu()<cr>


# remove buffer editing mappings
for key in nop_maps
    exe $'noremap <buffer> {key} <nop>'
    exe $'xnoremap <buffer> {key} <nop>'
endfor
