vim9script

import autoload 'dir/g.vim'


export def Info(bufnr: number): string
    var sort_by = getbufvar(bufnr, "dir_sort_by", "name")
    var sort_d = getbufvar(bufnr, "dir_sort_desc", false)

    return $'Sort by {sort_by} {(sort_d ? "▼" : "▲")}'
enddef


export def BySize(dir: list<dict<any>>, desc: bool = false)
    if desc
        dir->sort((d1, d2) => {
            if !g.IsFile(d2) && !g.IsFile(d1) || g.IsFile(d2) && g.IsFile(d1)
                if d2.size > d1.size
                    return 1
                elseif d2.size < d1.size
                    return -1
                else
                    return 0
                endif
            else
                return 0
            endif
        })
    else
        dir->sort((d1, d2) => {
            if !g.IsFile(d2) && !g.IsFile(d1) || g.IsFile(d2) && g.IsFile(d1)
                if d2.size > d1.size
                    return -1
                elseif d2.size < d1.size
                    return 1
                else
                    return 0
                endif
            else
                return 0
            endif
        })
    endif
enddef


export def ByTime(dir: list<dict<any>>, desc: bool = false)
    if desc
        dir->sort((d1, d2) => {
            if !g.IsFile(d2) && !g.IsFile(d1) || g.IsFile(d2) && g.IsFile(d1)
                if d2.time > d1.time
                    return 1
                elseif d2.time < d1.time
                    return -1
                else
                    return 0
                endif
            else
                return 0
            endif
        })
    else
        dir->sort((d1, d2) => {
            if !g.IsFile(d2) && !g.IsFile(d1) || g.IsFile(d2) && g.IsFile(d1)
                if d2.time > d1.time
                    return -1
                elseif d2.time < d1.time
                    return 1
                else
                    return 0
                endif
            else
                return 0
            endif
        })
    endif
enddef


export def ByName(dir: list<dict<any>>, desc: bool = false)
    if desc
        dir->sort((d1, d2) => {
            if !g.IsFile(d2) && !g.IsFile(d1) || g.IsFile(d2) && g.IsFile(d1)
                if d2.name > d1.name
                    return 1
                elseif d2.name < d1.name
                    return -1
                else
                    return 0
                endif
            else
                return 0
            endif
        })
    else
        dir->sort((d1, d2) => {
            if !g.IsFile(d2) && !g.IsFile(d1) || g.IsFile(d2) && g.IsFile(d1)
                if d2.name > d1.name
                    return -1
                elseif d2.name < d1.name
                    return 1
                else
                    return 0
                endif
            else
                return 0
            endif
        })
    endif
enddef
