vim9script


def Perm(e: dict<any>): string
    return (e.type == 'file' ? '-' : e.type[0]) .. e.perm
enddef


def Name(e: dict<any>): string
    return e.name .. (e.type =~ 'link' ? ' -> ' .. resolve(e.name) : '')
enddef


def Size(s: number): string
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


def Time(t: number): string
    return strftime("%Y-%m-%d %H:%M", t)
enddef


export def Dir(e: dict<any>): string
    if has("win32")
        return printf("%s %6s %s %s",
                  Perm(e),
                  Size(e.size),
                  Time(e.time),
                  e.name)
    else
        return printf("%s %-8s %-8s %6s %s %s",
                  Perm(e),
                  e.user,
                  e.group,
                  Size(e.size),
                  Time(e.time),
                  Name(e))
    endif
enddef
