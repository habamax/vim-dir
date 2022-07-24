vim9script

import autoload 'dir/g.vim'

var mark_list: list<dict<any>> = []
var mark_dir: string = ""
var mark_bufnr: number = -1

prop_type_add('DirMark', {highlight: 'DirMark', priority: 1000})


def ClearOtherBufferMarks()
    for buf_info in g.OtherDirBuffers()
        prop_clear(1, buf_info.linecount, {type: 'DirMark', bufnr: buf_info.bufnr})
    endfor
enddef


# Assuming all textprop marks were deleted after sort
# This should re-create them
export def RefreshVisual()
    if IsEmpty() | return | endif
    if mark_dir != b:dir_cwd | return | endif
    if mark_list->len() == b:dir->len()
        prop_clear(g.DIRLIST_SHIFT, line('$'), {type: 'DirMark'})
        prop_add(g.DIRLIST_SHIFT, 1, {type: 'DirMark', end_lnum: line('$'), end_col: 500})
        return
    endif

    for item in mark_list
        var idx = b:dir->index(item)
        if idx != -1
            prop_add(idx + g.DIRLIST_SHIFT, 1, {type: 'DirMark', length: 500})
        endif
    endfor
enddef


export def List(): list<dict<any>>
    return mark_list
enddef


export def Dir(): string
    return mark_dir
enddef


export def Bufnr(): number
    return mark_bufnr
enddef


export def UpdateInfo()
    var cnt = mark_list->len()
    for buf_info in g.DirBuffers()
        setbufvar(buf_info.bufnr, '&modifiable', 1)
        setbufvar(buf_info.bufnr, '&readonly', 0)
        if cnt > 0
            var dir = buf_info.bufnr == mark_bufnr ? '' : $' in {mark_dir}'
            setbufline(buf_info.bufnr, 2, $"Selected: {cnt}{dir}")
        else
            setbufline(buf_info.bufnr, 2, "")
        endif
        setbufvar(buf_info.bufnr, '&modified', 0)
        setbufvar(buf_info.bufnr, '&modifiable', 0)
        setbufvar(buf_info.bufnr, '&readonly', 1)
    endfor
enddef


export def Toggle(items: list<dict<any>>, line1: number, line2: number)
    if bufnr() != mark_bufnr
        Clear()
    endif
    for el in items
        var idx = mark_list->index(el)
        if idx != -1
            mark_list->remove(idx)
        else
            mark_list->add(el)
        endif
    endfor
    mark_dir = b:dir_cwd
    mark_bufnr = bufnr()

    UpdateInfo()

    for line in range(min([line1, line2]), max([line1, line2]))
        if empty(prop_list(line, {types: ['DirMark']}))
            prop_add(line, 1, {type: 'DirMark', length: 500})
        else
            prop_clear(line, line, {type: 'DirMark'})
        endif
    endfor
enddef


export def Clear()
    mark_list = []
    mark_dir = ""
    mark_bufnr = -1
    prop_clear(1, line('$'), {type: 'DirMark'})
    ClearOtherBufferMarks()
    UpdateInfo()
enddef


export def All()
    mark_list = b:dir->copy()
    mark_dir = b:dir_cwd
    mark_bufnr = bufnr()
    prop_clear(g.DIRLIST_SHIFT, line('$'), {type: 'DirMark'})
    prop_add(g.DIRLIST_SHIFT, 1, {type: 'DirMark', end_lnum: line('$'), end_col: 500})
    ClearOtherBufferMarks()
    UpdateInfo()
enddef

export def ToggleAll()
    if IsEmpty()
        All()
    elseif mark_bufnr == bufnr()
        Clear()
    else
        Clear()
        All()
    endif
enddef


export def IsEmpty(): bool
    return len(mark_list) == 0
enddef


# export def DebugPrint()
#     echo mark_list->mapnew((_, v) => $"[{v.type}]\t{v.name}")->join("\n")
#     echo $"count: {mark_list->len()}"
#     echo $"Mark Dir: {mark_dir}"
#     echo $"Mark Buffer: {mark_bufnr}"
# enddef
