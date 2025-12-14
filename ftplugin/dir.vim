vim9script

if exists("b:did_ftplugin")
    finish
endif
b:did_ftplugin = 1

var undo_opts = "setl spell< buftype< bufhidden< buflisted< swapfile<"

setlocal nospell
setlocal buftype=nofile
setlocal bufhidden=hide
setlocal nobuflisted
setlocal noswapfile


var nop_maps = ['r', 'd', 'c', 'a', 'I', 'K',
                'gp', 'gP', 'gi', 'gI', 'gu', 'gU',  'gH', 'gw',
                'U', '<C-w>f', '<C-w>F', 'gf', 'gF'
               ]
var undo_maps = ['-', '<bs>', '\<cr>', 'u', 'o', 'O', 'S', 's', 'A',
                 '~', 'g~', 'gb', 'gh', '>', '<', 'gj', '<C-r>',
                 't', 'i', 'x', 'X', 'C', 'cc', 'D', 'dd', 'R', 'rr', 'p', 'P',
                 'g1', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7', 'g8', 'g9', 'g0',
                 '<C-a>1', '<C-a>2', '<C-a>3', '<C-a>4', '<C-a>5',
                 '<C-a>6', '<C-a>7', '<C-a>8', '<C-a>9', '<C-a>0',
                 'gq', 'g/', 'g.', 'g,', 'ge', ']]', '[[', '.',
                 '<F2>', '<F3>', '<F4>', '<F5>', '<F6>', '<F7>', '<F8>'
                ]

b:undo_ftplugin = undo_opts .. ' | '
b:undo_ftplugin ..= (nop_maps + undo_maps)->mapnew((_, v) => $'exe "unmap <buffer> {v}"')->join(' | ')

if !get(g:, "dir_change_cwd", 0)
    augroup dir_cwd
        au!
        au BufLeave <buffer> exe "lcd" getcwd(-1)
    augroup END
endif


import autoload 'dir.vim'
import autoload 'dir/action.vim'


command! -buffer -nargs=? -bang DirFilter action.DoFilter("<bang>", <f-args>)
command! -buffer -nargs=? -bang DirFilterClear action.DoFilterClear()
command! -buffer DirBookmark action.BookmarkSet()
command! -buffer -nargs=1 -complete=custom,action.BookmarkComplete DirBookmarkJump action.BookmarkJump(<q-args>)
command! -buffer -nargs=1 -complete=custom,action.HistoryComplete DirHistoryJump action.HistoryJump(<q-args>)

nnoremap <buffer><nowait> <bs> <scriptcmd>action.DoUp()<cr>
nnoremap <buffer><nowait> - <scriptcmd>action.DoUp()<cr>
nnoremap <buffer><nowait> u <scriptcmd>action.DoUp()<cr>
xnoremap <buffer><nowait> u <scriptcmd>action.DoUp()<cr>
nnoremap <buffer><nowait> <cr> <scriptcmd>action.Do()<cr>
nnoremap <buffer><nowait> o <scriptcmd>action.Do()<cr>
nnoremap <buffer><nowait> <F4> <scriptcmd>action.Do()<cr>
nnoremap <buffer><nowait> O <scriptcmd>action.DoOS()<cr>
nnoremap <buffer><nowait> S <scriptcmd>action.Do($"{g:dir_invert_split ? '' : 'vert'} split")<cr>
xnoremap <buffer><nowait> S <nop>
nnoremap <buffer><nowait> s <scriptcmd>action.Do($"{g:dir_invert_split ? 'vert' : ''} split")<cr>
xnoremap <buffer><nowait> s <nop>
nnoremap <buffer><nowait> t <scriptcmd>action.Do("tabe")<cr>
nnoremap <buffer><nowait> i <scriptcmd>action.DoInfo()<cr>
nnoremap <buffer><nowait> <F3> <scriptcmd>action.DoInfo()<cr>
nnoremap <buffer><nowait> <C-r> <scriptcmd>edit<cr>


noremap  <buffer><nowait> x <scriptcmd>action.DoMarkToggle()<cr>j
xnoremap <buffer><nowait> x <scriptcmd>action.DoMarkToggle()<cr><ESC>j
noremap  <buffer><nowait> X <scriptcmd>action.DoMarksAllToggle()<cr>
xnoremap <buffer><nowait> X <scriptcmd>action.DoMarksAllToggle()<cr>
noremap  <buffer><nowait> D <scriptcmd>action.DoDelete()<cr>
xnoremap <buffer><nowait> D <scriptcmd>action.DoDelete()<cr>
noremap  <buffer><nowait> C <scriptcmd>action.DoCreateDir()<cr>
noremap  <buffer><nowait> cc <scriptcmd>action.DoCreateFile()<cr>
noremap  <buffer><nowait> <F7> <scriptcmd>action.DoCreateDir()<cr>
xnoremap <buffer><nowait> C <nop>
noremap  <buffer><nowait> dd <scriptcmd>action.DoDelete()<cr>
xnoremap <buffer><nowait> dd <scriptcmd>action.DoDelete()<cr>
noremap  <buffer><nowait> <F8> <scriptcmd>action.DoDelete()<cr>
xnoremap <buffer><nowait> <F8> <scriptcmd>action.DoDelete()<cr>
noremap  <buffer><nowait> p <scriptcmd>action.DoCopy()<cr>
xnoremap <buffer><nowait> p <scriptcmd>action.DoCopy()<cr>
noremap  <buffer><nowait> <F5> <scriptcmd>action.DoCopy2Pane()<cr>
xnoremap <buffer><nowait> <F5> <scriptcmd>action.DoCopy2Pane()<cr>
noremap  <buffer><nowait> P <scriptcmd>action.DoMove()<cr>
xnoremap <buffer><nowait> P <scriptcmd>action.DoMove()<cr>
noremap  <buffer><nowait> <F6> <scriptcmd>action.DoMove2Pane()<cr>
xnoremap <buffer><nowait> <F6> <scriptcmd>action.DoMove2Pane()<cr>
noremap  <buffer><nowait> R <scriptcmd>action.DoRename()<cr>
xnoremap <buffer><nowait> R <scriptcmd>action.DoRename()<cr>
noremap  <buffer><nowait> rr <scriptcmd>action.DoRename()<cr>
xnoremap <buffer><nowait> rr <scriptcmd>action.DoRename()<cr>
nnoremap <buffer><nowait> A <scriptcmd>action.DoAction()<cr>
xnoremap <buffer><nowait> A <scriptcmd>action.DoAction()<cr>
nnoremap <buffer><nowait> <F2> <scriptcmd>action.DoAction()<cr>
xnoremap <buffer><nowait> <F2> <scriptcmd>action.DoAction()<cr>
nnoremap <buffer><nowait> g, <scriptcmd>action.DoSort("size")<cr>
nnoremap <buffer><nowait> g. <scriptcmd>action.DoSort("time")<cr>
nnoremap <buffer><nowait> g/ <scriptcmd>action.DoSort("name")<cr>
nnoremap <buffer><nowait> ge <scriptcmd>action.DoSort("extension")<cr>

nnoremap <buffer><nowait> . <scriptcmd>action.DoFilterHidden()<cr>

noremap  <buffer><nowait> ]] <scriptcmd>action.JumpForward()<cr>
noremap  <buffer><nowait> [[ <scriptcmd>action.JumpBackward()<cr>

nnoremap <buffer><nowait> ~ <scriptcmd>Dir ~<cr>
nnoremap <buffer><nowait> g~ <scriptcmd>Dir ~<cr>
for idx in range(10)
    exe $'nnoremap <buffer><nowait> g{idx} <scriptcmd>action.BookmarkJumpNum({idx})<cr>'
    exe $'nnoremap <buffer><nowait> <C-a>{idx} <scriptcmd>action.BookmarkSetNum({idx})<cr>'
endfor

nnoremap <buffer><nowait> gb <scriptcmd>action.BookmarkJumpMenu()<cr>
nnoremap <buffer><nowait> gh <scriptcmd>action.HistoryJumpMenu()<cr>
nnoremap <buffer><nowait> gj <scriptcmd>action.GotoMenu()<cr>

noremap  <buffer><nowait> > <scriptcmd>action.WidenView()<cr>
noremap  <buffer><nowait> < <scriptcmd>action.ShrinkView()<cr>

nnoremap <buffer><nowait> gq <C-w>c

# remove buffer editing mappings
for key in nop_maps
    exe $'noremap <buffer> {key} <nop>'
    exe $'xnoremap <buffer> {key} <nop>'
endfor
