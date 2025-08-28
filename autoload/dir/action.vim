vim9script

import autoload 'dir.vim'
import autoload 'dir/g.vim'
import autoload 'dir/popup.vim'
import autoload 'dir/os.vim'
import autoload 'dir/mark.vim'
import autoload 'dir/bookmark.vim'
import autoload 'dir/history.vim'
import autoload 'dir/fmt.vim'

export def VisualItemsInList(line1: number, line2: number): list<dict<any>>
    var l1 = (line1 > line2 ? line2 : line1) - g.DIRLIST_SHIFT
    var l2 = (line2 > line1 ? line2 : line1) - g.DIRLIST_SHIFT
    if l2 < 0 | return [] | endif
    if l1 < 0 && l2 >= 0 | l1 = 0 | endif
    return b:dir[l1 : l2]
enddef

export def CursorItemInList(): dict<any>
    var idx = line('.') - g.DIRLIST_SHIFT
    if idx < 0 | return {name: ""} | endif
    return b:dir[idx]
enddef

export def CursorItem(): string
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
        popup.Show(readfile($"{path}", "", g.PREVIEW_LINES), item, (winid) => {
            var fname = fnamemodify(item, ":t")
            for [syn, pat] in g.PREVIEW_SYNTAX_MAP
                if fname =~ pat
                    win_execute(winid, $"setl syntax={syn}")
                    return
                endif
            endfor
            win_execute(winid, "filetype detect")
        })
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
        var path = isabsolutepath(item) ? item : $"{b:dir_cwd}/{item}"
        os.Open(path)
        history.Add(b:dir_cwd)
    endif
enddef

export def DoSort(by: string)
    if ["time", "size", "name", "extension"]->index(by) == -1 | return | endif

    if (get(b:, "dir_sort_by") ?? get(g:, "dir_sort_by", "name")) == by
        b:dir_sort_desc = !get(b:, "dir_sort_desc", false)
    else
        b:dir_sort_desc = false
    endif

    b:dir_sort_by = by

    dir.SortDir(b:dir)
    dir.PrintDir(b:dir)
    dir.UpdateStatusInfo()
    mark.RefreshVisual()

    g.Echo("Sort by ", {t: $'{by} {(b:dir_sort_desc ? "▼" : "▲")}', hl: 'WarningMsg'})
enddef

export def DoFilterHidden()
    g:dir_show_hidden = !get(g:, "dir_show_hidden", "true")
    b:dir_invalidate = true
    :edit

    var msg = g:dir_show_hidden ? "Show" : "Hide"
    g.Echo({t: msg, hl: "WarningMsg"}, " .hidden")
enddef

export def DoFilter(bang: string, fltr: string)
    b:dir_filter = fltr
    b:dir_filter_bang = bang
    :edit

    var msg = (empty(bang) ? "Show" : "Hide")
    g.Echo($"{msg} matched ", {t: $"{fltr}", hl: "WarningMsg"})
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
        dir.UpdateStatusInfo()
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
                    os.Delete(isabsolutepath(item.name) ? item.name : $"{b:dir_cwd}/{item.name}")
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
        dir.UpdateStatusInfo()
    endif
enddef

export def DoMarksAllToggle()
    mark.ToggleAll()
    dir.UpdateStatusInfo()
enddef

export def DoRename()
    var del_list = []
    if mark.IsEmpty() || mark.Bufnr() != bufnr()
        mark.Clear()
        del_list = VisualItemsInList(line('v'), line('.'))
    else
        del_list = mark.List()
        mark.Clear()
    endif

    if len(del_list) == 0 | return | endif

    if len(del_list) > 1
        var input_pat = "{name}{ext}"
        var pattern = input("Rename with pattern: ", input_pat)
        if pattern->trim() == input_pat->trim() | return | endif
        if pattern->trim() !~ "{name}" | return | endif
        var view = winsaveview()
        var counter = 0
        for item in del_list
            os.RenameWithPattern($"{b:dir_cwd}/{item.name}", pattern, counter)
            counter += 1
        endfor
        :edit
        winrestview(view)
    else
        var view = winsaveview()
        os.Rename($"{b:dir_cwd}/{del_list[0].name}")
        :edit
        winrestview(view)
    endif
enddef

export def DoCopy()
    if mark.IsEmpty() | return | endif

    # check if user wants to copy a directory into its own subdirectory... and prevent it.
    for item in mark.List()
        if item.type !~ 'dir\|linkd\|junction' | continue | endif
        var path = $"{mark.Dir()}{os.Sep()}{item.name}"
        if path == strpart(b:dir_cwd, 0, path->len())
            echohl Error
            echomsg "Can't copy to self sub directory!"
            echohl None
            return
        endif
    endfor

    var cnt = mark.List()->len()

    var msg = []
    if mark.Bufnr() == bufnr()
        if cnt == 1
            msg = [$'Duplicate {FileOrDirMsg(mark.List())} here?', $'"{mark.List()[0].name}"']
        else
            msg = [$'Duplicate {cnt} {FileOrDirMsg(mark.List())} here?']
        endif

        var res = popup.Confirm(msg, [{text: "&yes", act: 'y'}, {text: "&no", act: 'n'}])
        if res == 0
            var view = winsaveview()
            os.Duplicate()
            winrestview(view)
            :edit
        endif
    else
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
    endif
enddef

export def DoCopy2Pane()
    echo "Two panes copy is not implemented!"
enddef

export def DoMove()
    if mark.IsEmpty() | return | endif
    if mark.Bufnr() == bufnr()
        echohl Error
        echomsg "Can't move to the same location!"
        echohl None
        return
    endif
    # check if user wants to move a directory into its own subdirectory... and prevent it.
    for item in mark.List()
        if item.type !~ 'dir\|linkd\|junction' | continue | endif
        var path = $"{mark.Dir()}{os.Sep()}{item.name}"
        if path == strpart(b:dir_cwd, 0, path->len())
            echohl Error
            echomsg "Can't move to self sub directory!"
            echohl None
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
        RefreshOtherDirWindows()
    endif
enddef

export def DoMove2Pane()
    echo "Two panes move is not implemented!"
enddef

export def DoCreateDir()
    var name = input($'Create directory: ')
    if empty(name) | return | endif
    var view = winsaveview()
    if !isabsolutepath(name)
        name = $"{b:dir_cwd}/{name}"
    endif
    if os.CreateDir(name)
        :edit
        winrestview(view)
        var first_dir = split(name, '[/\\]')[0]
        var idx = b:dir->indexof((_, val) => val.name == first_dir)
        if idx > -1
            exe $":{idx + g.DIRLIST_SHIFT}"
        endif
    endif
enddef

export def DoCreateFile()
    var name = input($'Create file: ')
    if empty(name) | return | endif
    var view = winsaveview()
    if !isabsolutepath(name)
        name = $"{b:dir_cwd}/{name}"
    endif
    exe "edit" name
enddef

export def DoCompressGzip(items: list<any>)
    var arch_name = input('Archive name: ', fnamemodify(items[0].name, ":t:r"))
    if empty(arch_name) | return | endif
    if arch_name !~ '^\S.*\.tar.gz$'
        arch_name ..= '.tar.gz'
    endif
    var view = winsaveview()
    mark.Clear()
    if os.CompressGzip(arch_name, items)
        :edit
        winrestview(view)
        var idx = b:dir->indexof((_, val) => val.name == arch_name)
        if idx > -1
            exe $":{idx + g.DIRLIST_SHIFT}"
        endif
    endif
enddef

export def DoCompressZip(items: list<any>)
    var arch_name = input('Archive name: ', fnamemodify(items[0].name, ":t:r"))
    if empty(arch_name) | return | endif
    if arch_name !~ '^\S.*zip$'
        arch_name ..= '.zip'
    endif
    var view = winsaveview()
    mark.Clear()
    if os.CompressZip(arch_name, items)
        :edit
        winrestview(view)
        var idx = b:dir->indexof((_, val) => val.name == arch_name)
        if idx > -1
            exe $":{idx + g.DIRLIST_SHIFT}"
        endif
    endif
enddef

export def DoExtractArch(items: list<any>)
    # XXX: need to add more checks and control:
    # - extract to directory named after archive file-name
    # - what to do if files/directories in archive are already present?
    #   as of now they just overriden silently.
    if items->len() != 1 | return | endif
    var view = winsaveview()
    var dir_name = input('Extract to: ', fnamemodify(items[0].name, ":t:r:r"))
    mark.Clear()
    if os.ExtractArch($"{b:dir_cwd}/{items[0].name}", $"{b:dir_cwd}/{dir_name}")
        :edit
        winrestview(view)
    endif
enddef

export def DoAction()
    var actions = [
        {text: 'Compress to tar.gz', Action: DoCompressGzip},
        {text: 'Compress to zip', Action: DoCompressZip}
    ]

    var items = []
    if mark.IsEmpty()
        items = VisualItemsInList(line('v'), line('.'))
    else
        items = mark.List()
    endif

    if items->len() == 1
        if items[0].name =~ '\.\(zip\|[xg]z\)$'
            actions->add({text: 'Extract archive', Action: DoExtractArch})
        endif
    endif

    # TODO: document custom user actions
    extend(actions, get(g:, "dir_actions", []))

    popup.Select('Actions', actions,
        (res, _) => {
            res.Action(items)
        })
enddef

export def ShrinkView()
    var columns = fmt.Columns()
    if columns->split(',')->len() <= 1 | return | endif
    if columns =~ 'user,group,'
        columns = columns->substitute('user,group,', '', '')
    elseif columns =~ 'perm,'
        columns = columns->substitute('perm,', '', '')
    elseif columns =~ 'size,'
        columns = columns->substitute('size,', '', '')
    elseif columns =~ 'time,'
        columns = columns->substitute('time,', '', '')
    endif
    fmt.SetColumns(columns)
    dir.PrintDir(b:dir)
    dir.UpdateStatusInfo()
    mark.RefreshVisual()
    RefreshOtherDirWindows()
enddef

export def WidenView()
    var columns = fmt.Columns()
    if columns->split(',')->len() >= (has("win32") ? 4 : 6) | return | endif
    if columns !~ 'time,'
        columns = columns->substitute('name', 'time,name', '')
    elseif columns !~ 'size,'
        columns = columns->substitute('time', 'size,time', '')
    elseif columns !~ 'perm,'
        columns = columns->substitute('size', 'perm,size', '')
    elseif columns !~ 'user,group,' && !has("win32")
        columns = columns->substitute('perm', 'perm,user,group', '')
    endif
    fmt.SetColumns(columns)
    dir.PrintDir(b:dir)
    dir.UpdateStatusInfo()
    mark.RefreshVisual()
    RefreshOtherDirWindows()
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


export def BookmarkJump(name: string, cmd: string = "")
    if !empty(cmd)
        execute(cmd)
    endif
    bookmark.Jump(name)
enddef


export def BookmarkJumpMenu()
    var bookmarks = bookmark.NamesAndPaths()
    if empty(bookmarks)
        echohl Error
        echomsg $'There are no bookmarks!'
        echohl None
        return
    endif
    popup.Select('Dir bookmarks', bookmarks->mapnew((_, v) => {
            return {text: v[0], posttext: $' ({v[1]})', name: v[0]}
        }),
        (res, key) => {
            if key == "\<c-t>"
                BookmarkJump(res.name, "tabnew")
            elseif key == "\<c-j>"
                BookmarkJump(res.name, "split")
            elseif key == "\<c-v>"
                BookmarkJump(res.name, "vert split")
            else
                BookmarkJump(res.name)
            endif
        },
        (winid) => {
            win_execute(winid, 'syn match dirPopupSelectBookmarkPath "(.*)$"')
            hi def link dirPopupSelectBookmarkPath Comment
        })
enddef


export def BookmarkSet()
    var name = input("Bookmark name: ", fnamemodify(b:dir_cwd, ':t'))
    if empty(name)
        return
    endif
    redraw
    if bookmark.Exists(name)

        var msg = [$'Bookmark "{name}" exists!', $'{bookmark.Get(name)}', 'Override?']
        var res = popup.Confirm(msg, [{text: "&yes", act: 'y'}, {text: "&no", act: 'n'}])
        if res != 0
            return
        endif
    endif
    bookmark.Set(name, b:dir_cwd)
enddef

export def BookmarkJumpNum(n: number)
    bookmark.JumpNum(n)
enddef

export def BookmarkSetNum(n: number)
    bookmark.SetNum(n)
enddef

export def BookmarkComplete(_, _, _): string
    return bookmark.Names()->join("\n")
enddef

export def HistoryJumpMenu()
    var dir_hist = history.Paths()
    if empty(dir_hist)
        echohl Error
        echomsg $'There is no history yet!'
        echohl None
        return
    endif
    popup.Select('Dir history', dir_hist,
        (res, key) => {
            if key == "\<c-t>"
                HistoryJump(res.text, "tabnew")
            elseif key == "\<c-j>"
                HistoryJump(res.text, "split")
            elseif key == "\<c-v>"
                HistoryJump(res.text, "vert split")
            else
                HistoryJump(res.text)
            endif
        },
        (winid) => {
            win_execute(winid, 'syn match dirPopupSelectHistoryPath "^.*\(/\|\\\)"')
            hi def link dirPopupSelectHistoryPath Comment
        })
enddef

export def HistoryJump(name: string, cmd: string = "")
    if !empty(cmd)
        execute(cmd)
    endif
    dir.Open(name)
enddef

export def HistoryComplete(_, _, _): string
    return history.Paths()->join("\n")
enddef

export def GotoMenu()
    popup.Select('Jump to', b:dir->mapnew((idx, v) => {
            return {text: $'{g.IsFile(v) ? "" : os.Sep()}{v.name}', idx: idx}
        }),
        (res, _) => {
            exe $":{res.idx + g.DIRLIST_SHIFT}"
        },
        (winid) => {
            win_execute(winid, $'syn match dirPopupSelectDirectory "^{os.Sep(true)}.\+$"')
            hi def link dirPopupSelectDirectory Directory
        })
enddef

def RefreshOtherDirWindows()
    for buf_info in g.OtherDirBuffers()
        setbufvar(buf_info.bufnr, "dir_invalidate", true)
        for winid in buf_info.windows
            win_execute(winid, ":edit", "silent!")
        endfor
    endfor
enddef
