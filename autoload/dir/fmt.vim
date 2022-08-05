vim9script


var columns: string
if has("win32")
    columns = get(g:, "dir_columns", "") ?? "perm,size,time,name"
else
    columns = get(g:, "dir_columns", "") ?? "perm,user,group,size,time,name"
endif


def Perm(e: dict<any>): string
    return (e.type == 'file' ? '-' : e.type[0]) .. e.perm
enddef


def Name(e: dict<any>): string
    return e.name .. (e.type =~ 'link' ? ' -> ' .. resolve(e.name) : '')
enddef


def Size(e: dict<any>): string
    if e.size >= 10 * 1073741824
        return $"{e.size / 1073741824}G"
    elseif e.size >= 10 * 1048576
        return $"{e.size / 1048576}M"
    elseif e.size >= 1048576
        return $"{e.size / 1024}K"
    else
        return $"{e.size}"
    endif
enddef


def Time(e: dict<any>): string
    return strftime("%Y-%m-%d %H:%M", e.time)
enddef


def User(e: dict<any>): string
    return e.user
enddef


def Group(e: dict<any>): string
    return e.group
enddef


export def BuildPrintf(): func(dict<any>): string
    var columns_param: dict<any> = {
            perm: ["%s", Perm],
            user: ["%-8s", User],
            group: ["%-8s", Group],
            size: ["%7s", Size],
            time: ["%s", Time],
            name: ["%s", Name]
        }
    var fmt = []
    var fmt_f = []
    for item in split(columns, ',')
        fmt->add(columns_param[item][0])
        fmt_f->add(columns_param[item][1])
    endfor
    return (e: dict<any>): string => call("printf", [fmt->join(" ")] + fmt_f->mapnew((_, F) => F(e)))
enddef


var DirPrintf: func(dict<any>): string = BuildPrintf()


export def Columns(): string
    return columns
enddef


export def SetColumns(new_columns: string)
    columns = new_columns
    DirPrintf = BuildPrintf()
enddef


export def Dir(e: dict<any>): string
    return DirPrintf(e)
enddef
