vim9script

if exists('g:loaded_dir') || v:version < 900
    finish
endif
g:loaded_dir = 1

# if a file or dir is matched with this -- open in OS
g:dir_open_ext = ['\.pdf$', '\.ods$', '\.odt$', '\.odp$',
                  '\.xls$', '\.xlsx$', '\.doc$', '\.docx$', '\.ppt$', '\.pptx$',
                  '\.png$', '\.jpg$', '\.gif$',
                  '\.mkv$', '\.mov$', '\.mpeg$', '\.avi$', '\.mp4$',
                  '\.mp3$', '\.ogg$', '\.flac$'
                  ]

# By default s split horizontally, S vertically.
# Invert s and S.
g:dir_invert_split = 0


import autoload 'dir.vim'

command! -nargs=? -complete=dir Dir dir.Open(<f-args>)
