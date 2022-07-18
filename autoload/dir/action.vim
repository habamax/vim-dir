vim9script

import autoload 'dir.vim'
import autoload 'dir/popup.vim'
import autoload 'dir/os.vim'
import autoload 'dir/mark.vim'

const DIRLIST_SHIFT = 3


def VisualItemsInList(line1: number, line2: number): list<dict<any>>
    var l1 = (line1 > line2 ? line2 : line1) - DIRLIST_SHIFT
    var l2 = (line2 > line1 ? line2 : line1) - DIRLIST_SHIFT
    if l2 < 0 | return [] | endif
    if l1 < 0 && l2 >= 0 | l1 = 0 | endif

    var cwd = trim(b:dir_cwd, '/\', 2)
    return b:dir[l1 : l2]->mapnew((_, v) => ({ type: v.type, name: $"{cwd}{os.Sep()}{v.name}"}))
enddef


def CursorItemInList(): string
    var idx = line('.') - DIRLIST_SHIFT
    if idx < 0 | return "" | endif
    var cwd = trim(b:dir_cwd, '/\', 2)
    return $"{cwd}{os.Sep()}{b:dir[idx].name}"
enddef


def CursorItem(): string
    if line('.') == 1
        var view = winsaveview()
        var new_dir = getline(1)[0 : searchpos($'{os.Sep()->escape("\\")}\|$', 'c', 1)[1] - 1]
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


export def DoInfo()
    var idx = line('.') - 3
    if idx < 0 | return | endif
    var cwd = trim(b:dir_cwd, '/', 2)
    var path = $"{cwd}{os.Sep()}{b:dir[idx].name}"
    if filereadable(path)
        popup.Show(readfile($"{cwd}{os.Sep()}{b:dir[idx].name}", "", 100), $"{b:dir[idx].name}")
    elseif isdirectory(path)
        popup.Show(os.DirInfo(path), path)
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
                $'Delete {del_list[0].type =~ "file\\|link" ? "file" : "directory"}',
                $'"{fnamemodify(del_list[0].name, ":t")}"?'
            ]
        else
            var file_or_dir = del_list->reduce((acc, el) => el.type =~ 'file\|link' ? or(acc, 1) : or(acc, 2), 0)
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


export def DoMark()
    var file_list = VisualItemsInList(line('v'), line('.'))
    if len(file_list) > 0
        mark.Add(file_list)
    endif
enddef


export def DoClearMarks()
    mark.Clear()
enddef


export def DoCopy()
    var view = winsaveview()
    try
        os.Copy()
    finally
        :edit
        winrestview(view)
    endtry
enddef


export def DoRename()
    var del_list = VisualItemsInList(line('v'), line('.'))
    if mode() =~ '[vV]' && len(del_list) > 1
        var input_pat = "{name}{ext}"
        var pattern = input("Rename with pattern: ", input_pat)
        if pattern->trim() == input_pat->trim() | return | endif
        if pattern->trim() !~ "{name}" | return | endif
        var view = winsaveview()
        var counter = 0
        for item in del_list
            os.RenameWithPattern(item.name, pattern, counter)
            counter += 1
        endfor
        :edit
        winrestview(view)
    else
        var view = winsaveview()
        os.Rename(del_list[0].name)
        :edit
        winrestview(view)
    endif
enddef


export def DoMove()
    echo "Move stub"
enddef


export def DoCreateDir()
    var view = winsaveview()
    os.CreateDir()
    :edit
    winrestview(view)
enddef


export def DoAction()
    var actions = []
    var del_list = VisualItemsInList(line('v'), line('.'))
    if len(del_list) == 1 && mode() !~ '[vV]'
        actions += [
            {name: "Create directory", Action: DoCreateDir},
        ]
    endif
    actions += [
        {name: "Rename", Action: DoRename}
        {name: "Delete", Action: DoDelete}
    ]
    popup.Menu(actions)
enddef
