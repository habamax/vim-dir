vim9script

import autoload 'dir/g.vim'


export def Info(bufnr: number): string
    var sort_by = getbufvar(bufnr, "dir_sort_by", "name")
    var sort_d = getbufvar(bufnr, "dir_sort_desc", false)

    return $'Sort by {sort_by} {(sort_d ? "▼" : "▲")}'
enddef


export def BySize(dir: list<dict<any>>, desc: bool = false)
    dir->sort((d1, d2) => {
        var ret = 0
        if !g.IsFile(d2) && !g.IsFile(d1) || g.IsFile(d2) && g.IsFile(d1)
            if d2.size > d1.size
                ret = -1
            elseif d2.size < d1.size
                ret = 1
            else
                ret = 0
            endif
        endif
        return ret * (desc ? -1 : 1)
    })
enddef


export def ByTime(dir: list<dict<any>>, desc: bool = false)
    dir->sort((d1, d2) => {
        var ret = 0
        if !g.IsFile(d2) && !g.IsFile(d1) || g.IsFile(d2) && g.IsFile(d1)
            if d2.time > d1.time
                ret = -1
            elseif d2.time < d1.time
                ret = 1
            else
                ret = 0
            endif
        endif
        return ret * (desc ? -1 : 1)
    })
enddef


export def ByName(dir: list<dict<any>>, desc: bool = false)
    dir->sort((d1, d2) => {
        var ret = 0
        if !g.IsFile(d2) && !g.IsFile(d1) || g.IsFile(d2) && g.IsFile(d1)
            if d2.name > d1.name
                ret = -1
            elseif d2.name < d1.name
                ret = 1
            else
                ret =  0
            endif
        endif
        return ret * (desc ? -1 : 1)
    })
enddef

export def ByExtension(dir: list<dict<any>>, desc: bool = false)
    dir->sort((d1, d2) => {
        var ret = 0
        if g.IsFile(d2) && g.IsFile(d1)
            const ext1 = d1.name->fnamemodify(':e')
            const ext2 = d2.name->fnamemodify(':e')
            if ext2 > ext1
                ret = -1
            elseif ext2 < ext1
                ret = 1
            else
                ret = 0
            endif
        endif
        return ret * (desc ? -1 : 1)
    })
enddef
