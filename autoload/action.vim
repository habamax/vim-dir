vim9script

import autoload './dir.vim'
import autoload './popup.vim'


export def Do(mod: string = '')
    if line('.') == 1
        var new_dir = getline(1)[0 : searchpos('/\|$', 'c', 1)[1] - 1]
        if isdirectory(new_dir)
            dir.Open(new_dir, mod)
        endif
    else
        var idx = line('.') - 3
        if idx < 0 | return | endif
        var cwd = trim(b:dir_cwd, '/', 2)
        dir.Open($"{cwd}/{b:dir[idx].name}", mod)
    endif
enddef


export def DoUp()
    dir.Open(fnamemodify(b:dir_cwd, ":h"))
enddef


export def DoPreview()
    var idx = line('.') - 3
    if idx < 0 | return | endif
    var cwd = trim(b:dir_cwd, '/', 2)
    if filereadable($"{cwd}/{b:dir[idx].name}")
        popup.Show(readfile($"{cwd}/{b:dir[idx].name}", "", 100), $"{b:dir[idx].name}")
    endif
enddef
