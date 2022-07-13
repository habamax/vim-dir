vim9script

import autoload 'dir.vim'
import autoload 'dir/popup.vim'
import autoload 'dir/os.vim'

const DIRLIST_SHIFT = 3


def VisualItemsInList(line1: number, line2: number): list<dict<any>>
    var l1 = (line1 > line2 ? line2 : line1) - DIRLIST_SHIFT
    var l2 = (line2 > line1 ? line2 : line1) - DIRLIST_SHIFT

    var cwd = trim(b:dir_cwd, '/', 2)
    return b:dir[l1 : l2]->mapnew((_, v) => ({ type: v.type, name: $"{cwd}/{v.name}"}))
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
    var del_list = VisualItemsInList(line('v'), line('.'))
    if !empty(del_list)
        var cnt = len(del_list)
        var msg = []
        if cnt == 1
            msg = [
                $'Delete {del_list[0].type =~ "file\\|link$" ? "file" : "directory"}',
                $'"{del_list[0].name}"?'
            ]
        else
            var file_or_dir = del_list->reduce((acc, el) => el.type =~ 'file\|link$' ? or(acc, 1) : or(acc, 2), 0)
            var items = {1: "files", 2: "directories", 3: "files/directories"}
            msg = [$'Delete {len(del_list)} {items[file_or_dir]}?']
        endif
        popup.Dialog(msg, () => {
            for item in del_list
                os.Delete(item.name)
            endfor
            :edit
        })
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
