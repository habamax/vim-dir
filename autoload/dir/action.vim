vim9script

import autoload 'dir.vim'
import autoload 'dir/popup.vim'
import autoload 'dir/os.vim'
import autoload 'dir/mark.vim'
import autoload 'dir/g.vim'


def VisualItemsInList(line1: number, line2: number): list<dict<any>>
    var l1 = (line1 > line2 ? line2 : line1) - g.DIRLIST_SHIFT
    var l2 = (line2 > line1 ? line2 : line1) - g.DIRLIST_SHIFT
    if l2 < 0 | return [] | endif
    if l1 < 0 && l2 >= 0 | l1 = 0 | endif
    return b:dir[l1 : l2]
enddef


def CursorItemInList(): dict<any>
    var idx = line('.') - g.DIRLIST_SHIFT
    if idx < 0 | return {name: ""} | endif
    return b:dir[idx]
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
        return CursorItemInList().name
    endif
    return ""
enddef


export def Do(mod: string = '')
    var item = CursorItem()
    if !empty(item)
        dir.Open(item, mod, false)
    endif
enddef


export def DoUp()
    dir.Open(fnamemodify(b:dir_cwd, ":h"), '', false)
enddef


export def DoInfo()
    var item = CursorItem()
    if empty(item) | return | endif
    var path = $"{b:dir_cwd}{os.Sep()}{item}"
    if filereadable(path)
        popup.Show(readfile($"{path}", "", 100), item)
    elseif isdirectory(path)
        var info = os.DirInfo(path)
        if !empty(info)
            popup.Show(info, item)
        endif
    endif
enddef


export def DoOS()
    var item = CursorItem()
    if !empty(item)
        os.Open(item)
    endif
enddef


export def DoSort(by: string)
    if ["time", "size", "name"]->index(by) == -1 | return | endif

    if (get(b:, "dir_sort_by") ?? get(g:, "dir_sort_by", "name")) == by
        b:dir_sort_desc = !get(b:, "dir_sort_desc", false)
    else
        b:dir_sort_desc = false
    endif

    b:dir_sort_by = by

    dir.SortDir(b:dir)
    dir.PrintDir(b:dir)
    mark.UpdateInfo()
    mark.RefreshVisual()

    g.Echo("Sort by ", {t: $'{by} {(b:dir_sort_desc ? "▼" : "▲")}', hl: 'WarningMsg'})
enddef


export def DoFilterHidden()
    g:dir_show_hidden = !get(g:, "dir_show_hidden", "true")
    b:dir_invalidate = true
    :edit

    var msg = g:dir_show_hidden ? "Show" : "Do not show"
    g.Echo({t: msg, hl: "WarningMsg"}, " .hidden files/directories.")
enddef


export def DoFilter(bang: string, fltr: string)
    b:dir_filter = fltr
    b:dir_filter_bang = bang
    :edit

    var msg = (empty(bang) ? "Hide" : "Show")
    g.Echo($"{msg} all matched ", {t: $"{fltr}", hl: "WarningMsg"})
enddef


export def DoFilterClear()
    b:dir_filter = ""
    b:dir_filter_bang = ""
    :edit

    g.Echo("Show all!")
enddef


def FileOrDirMsg(items: list<dict<any>>): string
    var cnt = len(items)
    if cnt == 0 | return "" | endif
    var res = ""
    if cnt == 1
        res = (items[0].type =~ "file\\|link" ? "file" : "directory")
    else
        var file_or_dir = items->reduce((acc, el) => el.type =~ 'file\|link' ? or(acc, 1) : or(acc, 2), 0)
        var types = {1: "files", 2: "directories", 3: "files/directories"}
        res = types[file_or_dir]
    endif
    return res
enddef


export def DoDelete()
    var del_list = []
    if mark.IsEmpty() || mark.Bufnr() != bufnr()
        mark.Clear()
        del_list = VisualItemsInList(line('v'), line('.'))
    else
        del_list = mark.List()
    endif
    if !empty(del_list)
        var cnt = len(del_list)
        var msg = []
        if cnt == 1
            msg = [$'Delete {FileOrDirMsg(del_list)}', $'"{del_list[0].name}"?']
        else
            msg = [$'Delete {len(del_list)} {FileOrDirMsg(del_list)}?']
        endif
        popup.YesNo(msg, () => {
            for item in del_list
                try
                    os.Delete(item.name)
                catch
                    echohl Error
                    echomsg $'Can not delete "{fnamemodify(item.name, ":t")}"!'
                    echohl None
                endtry
            endfor
            :edit
        })
    endif
enddef


export def DoMarkToggle()
    var file_list = VisualItemsInList(line('v'), line('.'))
    if len(file_list) > 0
        mark.Toggle(file_list, line('v'), line('.'))
    endif
enddef


export def DoMarksAllToggle()
    mark.ToggleAll()
enddef


export def DoRename()
    var del_list = []
    if mark.IsEmpty() || mark.Bufnr() != bufnr()
        mark.Clear()
        del_list = VisualItemsInList(line('v'), line('.'))
    else
        del_list = mark.List()
    endif

    if len(del_list) > 1
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


export def DoCopy()
    if mark.IsEmpty() | return | endif
    if mark.Bufnr() == bufnr()
        echo "Can't copy to the same location!"
        return
    endif
    # check if user wants to copy a directory into its own subdirectory... and prevent it.
    for item in mark.List()
        if item.type !~ 'dir\|linkd\|junction' | continue | endif
        var path = $"{mark.Dir()}{os.Sep()}{item.name}"
        if path == strpart(b:dir_cwd, 0, path->len())
            echo "Can't copy to self sub directory!"
            return
        endif
    endfor

    var cnt = mark.List()->len()

    var msg = []
    if cnt == 1
        msg = [$'Copy {FileOrDirMsg(mark.List())} here?', $'"{mark.List()[0].name}"']
    else
        msg = [$'Copy {cnt} {FileOrDirMsg(mark.List())} here?']
    endif

    var res = popup.Confirm(msg, [{text: "&yes", act: 'y'}, {text: "&no", act: 'n'}])
    if res == 0
        var view = winsaveview()
        os.Copy()
        winrestview(view)
        :edit
    endif
enddef


export def DoMove()
    if mark.IsEmpty() | return | endif
    if mark.Bufnr() == bufnr()
        echo "Can't move to the same location!"
        return
    endif
    # check if user wants to move a directory into its own subdirectory... and prevent it.
    for item in mark.List()
        if item.type !~ 'dir\|linkd\|junction' | continue | endif
        var path = $"{mark.Dir()}{os.Sep()}{item.name}"
        if path == strpart(b:dir_cwd, 0, path->len())
            echo "Can't move to self sub directory!"
            return
        endif
    endfor

    var cnt = mark.List()->len()

    var msg = []
    if cnt == 1
        msg = [$'Move {FileOrDirMsg(mark.List())} here?', $'"{mark.List()[0].name}"']
    else
        msg = [$'Move {cnt} {FileOrDirMsg(mark.List())} here?']
    endif

    var res = popup.Confirm(msg, [{text: "&yes", act: 'y'}, {text: "&no", act: 'n'}])
    if res == 0
        var view = winsaveview()
        os.Move()
        winrestview(view)
        :edit
    endif
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
    if len(del_list) <= 1 && mode() !~ '[vV]'
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


export def JumpForward()
    var idx = line('.') - g.DIRLIST_SHIFT
    if idx < 0
        idx = 0
    endif
    if g.IsFile(b:dir[idx])
        normal! G
    else
        while !g.IsFile(b:dir[idx]) && idx < len(b:dir) - 1
            idx += 1
        endwhile
        exe $":{idx + g.DIRLIST_SHIFT}"
    endif
enddef


export def JumpBackward()
    var idx = line('.') - g.DIRLIST_SHIFT
    if idx <= 0
        return
    elseif !g.IsFile(b:dir[idx])
        exe $":{g.DIRLIST_SHIFT}"
    else
        while g.IsFile(b:dir[idx]) && idx > 0
            idx -= 1
        endwhile
        exe $":{idx + g.DIRLIST_SHIFT}"
    endif
enddef
