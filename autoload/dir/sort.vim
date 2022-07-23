vim9script

def IsFile(item: dict<any>): bool
    return item.type == 'file' || item.type == 'link'
enddef


export def BySize(dir: list<dict<any>>, desc: bool = false)
    if desc
        dir->sort((d1, d2) => {
            if !IsFile(d2) && !IsFile(d1) || IsFile(d2) && IsFile(d1)
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
            if !IsFile(d2) && !IsFile(d1) || IsFile(d2) && IsFile(d1)
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
            if !IsFile(d2) && !IsFile(d1) || IsFile(d2) && IsFile(d1)
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
            if !IsFile(d2) && !IsFile(d1) || IsFile(d2) && IsFile(d1)
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
            if !IsFile(d2) && !IsFile(d1) || IsFile(d2) && IsFile(d1)
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
            if !IsFile(d2) && !IsFile(d1) || IsFile(d2) && IsFile(d1)
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
