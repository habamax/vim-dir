vim9script


export def Perm(e: dict<any>): string
    return (e.type == 'file' ? '-' : e.type[0]) .. e.perm
enddef


export def Name(e: dict<any>): string
    return e.name .. (e.type =~ 'link' ? ' -> ' .. resolve(e.name) : '')
enddef


export def Size(s: number): string
    if s >= 10 * 1073741824
        return $"{s / 1073741824}G"
    elseif s >= 10 * 1048576
        return $"{s / 1048576}M"
    elseif s >= 1048576
        return $"{s / 1024}K"
    else
        return $"{s}"
    endif
enddef


export def Time(t: number): string
    return strftime("%Y-%m-%d %H:%M", t)
enddef
