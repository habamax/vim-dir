vim9script


export def BySize(dir: list<dict<any>>, desc: bool = false)
    if desc
        dir->sort((d1, d2) => {
            if (d2.type != 'file' && d2.type != 'link' && d1.type != 'file' && d1.type != 'link') ||
               (d2.type == 'file' || d2.type == 'link') && (d1.type == 'file' || d1.type == 'link')
                return d2.size - d1.size
            else
                return 0
            endif
        })
    else
        dir->sort((d1, d2) => {
            if (d2.type != 'file' && d2.type != 'link' && d1.type != 'file' && d1.type != 'link') ||
               (d2.type == 'file' || d2.type == 'link') && (d1.type == 'file' || d1.type == 'link')
                return d1.size - d2.size
            else
                return 0
            endif
        })
    endif
enddef


export def ByTime(dir: list<dict<any>>, desc: bool = false)
    if desc
        dir->sort((d1, d2) => {
            if (d2.type != 'file' && d2.type != 'link' && d1.type != 'file' && d1.type != 'link') ||
               (d2.type == 'file' || d2.type == 'link') && (d1.type == 'file' || d1.type == 'link')
                return d2.time - d1.time
            else
                return 0
            endif
        })
    else
        dir->sort((d1, d2) => {
            if (d2.type != 'file' && d2.type != 'link' && d1.type != 'file' && d1.type != 'link') ||
               (d2.type == 'file' || d2.type == 'link') && (d1.type == 'file' || d1.type == 'link')
                return d1.time - d2.time
            else
                return 0
            endif
        })
    endif
enddef


export def ByName(dir: list<dict<any>>, desc: bool = false)
    if desc
        dir->sort((d1, d2) => {
            if (d2.type != 'file' && d2.type != 'link' && d1.type != 'file' && d1.type != 'link') ||
               (d2.type == 'file' || d2.type == 'link') && (d1.type == 'file' || d1.type == 'link')
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
            if (d2.type != 'file' && d2.type != 'link' && d1.type != 'file' && d1.type != 'link') ||
               (d2.type == 'file' || d2.type == 'link') && (d1.type == 'file' || d1.type == 'link')
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
