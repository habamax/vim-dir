vim9script

import autoload 'dir/os.vim'

var columns: string
if has("win32")
    columns = get(g:, "dir_columns", "") ?? "perm,size,time,name"
else
    columns = get(g:, "dir_columns", "") ?? "perm,user,group,size,time,name"
endif


var DirPrintf: func(dict<any>): string


def Perm(e: dict<any>): string
    return (e.type == 'file' ? '-' : e.type[0]) .. (e.perm ?? '---------')
enddef


def Name(e: dict<any>): string
    var res = e.name
    if e.type =~ 'link'
        res ..= ' -> ' .. resolve(e.name)
    endif
    if e.type == 'linkd' || e.type == 'dir' || e.type == 'junction'
        res = os.Sep() .. res
    endif
    return res
enddef


export def Size(e: dict<any>): string
    if e.size >= 10 * 1073741824 # 10G
        return printf("%.0fG", ceil(e.size / 1073741824.0))
    elseif e.size >= 10 * 1048576 # 10M
        return printf("%.0fM", ceil(e.size / 1048576.0))
    elseif e.size >= 1048576 # 1M
        return printf("%.1fM", e.size / 1048576.0)
    elseif e.size >= 10240 # 10K
        return printf("%.0fK", ceil(e.size / 1024.0))
    else
        return $"{e.size}"
    endif
enddef


def Time(e: dict<any>): string
    return strftime("%Y-%m-%d %H:%M", e.time)
enddef


def User(e: dict<any>): string
    return e.user ?? 'root'
enddef


def Group(e: dict<any>): string
    return e.group ?? 'root'
enddef


export def BuildPrintf(user_width: number, group_width: number, size_width: number): func(dict<any>): string
    var columns_param: dict<any> = {
            perm: ['%s', Perm],
            user: [$'%-{user_width}s', User],
            group: [$'%-{group_width}s', Group],
            size: [$'%{size_width}s', Size],
            time: ['%s', Time],
            name: ['%s', Name]
        }
    var fmt = []
    var fmt_f = []
    for item in split(columns, ',')
        fmt->add(columns_param[item][0])
        fmt_f->add(columns_param[item][1])
    endfor
    return (e: dict<any>): string => call("printf", [fmt->join(" ")] + fmt_f->mapnew((_, F) => F(e)))
enddef


export def Setup(user_width: number, group_width: number, size_width: number)
    DirPrintf = BuildPrintf(user_width, group_width, size_width)
enddef


export def Columns(): string
    return columns
enddef


export def SetColumns(new_columns: string)
    columns = new_columns
enddef


export def Dir(e: dict<any>): string
    return DirPrintf(e)
enddef
