vim9script

import autoload 'dir.vim'
import autoload 'dir/popup.vim'
import autoload 'dir/os.vim'


def CurrentItem(): string
    if line('.') == 1
        var view = winsaveview()
        var new_dir = getline(1)[0 : searchpos('/\|$', 'c', 1)[1] - 1]
        winrestview(view)
        if isdirectory(new_dir)
            return new_dir
        endif
    else
        var idx = line('.') - 3
        if idx < 0 | return "" | endif
        var cwd = trim(b:dir_cwd, '/', 2)
        return $"{cwd}/{b:dir[idx].name}"
    endif
    return ""
enddef


export def Do(mod: string = '')
    var item = CurrentItem()
    if !empty(item)
        dir.Open(item, mod)
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


export def DoOS()
    var item = CurrentItem()
    if !empty(item)
        os.Open(item)
    endif
enddef


export def DoDelete()
    echo "Delete stub"
enddef


export def DoCopy()
    echo "Copy stub"
enddef


export def DoPaste()
    echo "Paste stub"
enddef


export def DoRename()
    echo "Rename stub"
enddef
