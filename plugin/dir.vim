vim9script

if exists('g:loaded_dir') || v:version < 900
    finish
endif
g:loaded_dir = 1

g:dir_open_ext = ['\.pdf$', '\.ods$', '\.odt$', '\.odp$',
                  '\.xls$', '\.xlsx$', '\.doc$', '\.docx$', '\.ppt$', '\.pptx$',
                  '\.png$', '\.jpg$', '\.gif$',
                  '\.mkv$', '\.mov$', '\.mpeg$', '\.avi$', '\.mp4$',
                  '\.mp3$', '\.ogg$', '\.flac$'
                  ]

import autoload 'dir.vim'

command! -nargs=? -complete=dir Dir dir.Open(<f-args>)
