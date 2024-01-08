vim9script

if exists('g:loaded_dir') || v:version < 900
    finish
endif
g:loaded_dir = 1

# if a file or dir is matched with this -- open in OS
g:dir_open_os = [
    'pdf', 'ods', 'odt', 'odp',
    'xls', 'xlsx', 'doc', 'docx', 'ppt', 'pptx',
    'png', 'jpg', 'jpeg', 'gif',
    'mkv', 'mov', 'mpeg', 'avi', 'mp4', 'm4v', 'webm',
    'mp3', 'ogg', 'flac'
]

# By default s split horizontally, S vertically.
# Invert s and S.
g:dir_invert_split = 0


import autoload 'dir.vim'

command! -nargs=? -complete=dir Dir dir.Open(expand(<q-args>))

def g:DirOnDirectory()
    if !exists("b:dir") && isdirectory(expand("<afile>"))
        dir.Open()
    endif
enddef

augroup dirautocommands | au!
    au BufReadCmd dir://* dir.Open()

    if !exists(":Explore")
        au BufEnter * g:DirOnDirectory()
    endif
augroup END
