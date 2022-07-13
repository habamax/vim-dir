vim9script

import autoload 'dir.vim'
import autoload 'dir/popup.vim'
import autoload 'dir/os.vim'

const DIRLIST_SHIFT = 3


def VisualItemsInList(line1: number, line2: number): list<string>
    var l1 = (line1 > line2 ? line2 : line1) - DIRLIST_SHIFT
    var l2 = (line2 > line1 ? line2 : line1) - DIRLIST_SHIFT

    var cwd = trim(b:dir_cwd, '/', 2)
    return b:dir[l1 : l2]->mapnew((_, v) => $"{cwd}/{v.name}")
enddef


def CursorItemInList(): string
    var idx = line('.') - DIRLIST_SHIFT
    if idx < 0 | return "" | endif
    var cwd = trim(b:dir_cwd, '/', 2)
    return $"{cwd}/{b:dir[idx].name}"
enddef


def CursorItem(): string
    if line('.') == 1
        var view = winsaveview()
        var new_dir = getline(1)[0 : searchpos('/\|$', 'c', 1)[1] - 1]
        winrestview(view)
        if isdirectory(new_dir)
            return new_dir
        endif
    else
        return CursorItemInList()
    endif
    return ""
enddef


export def Do(mod: string = '')
    var item = CursorItem()
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
    var item = CursorItem()
    if !empty(item)
        os.Open(item)
    endif
enddef


export def DoDelete()
    if mode() =~ '[vV]'
        var del_list = VisualItemsInList(line('v'), line('.'))
        if !empty(del_list)
            popup.Dialog($'Delete {len(del_list)} files/directories?', () => {
                for item in del_list
                    os.Delete(item)
                endfor
                :edit
            })
        endif
    else
        var item = CursorItemInList()
        if !empty(item)
            popup.Dialog($'Delete {item}?', () => {
                os.Delete(item)
                :edit
            })
        endif
    endif
enddef


export def DoCopy()
    if mode() =~ '[vV]'
        echo "Copy visual stub"
        for l in VisualItemsInList(line('v'), line('.'))
            echo l
        endfor
    else
        echo "Copy stub" CursorItemInList()
    endif
enddef


export def DoPaste()
    echo "Paste stub"
enddef


export def DoRename()
    echo "Rename stub"
enddef


export def DoMove()
    echo "Move stub"
enddef
