vim9script

var mark_list: list<dict<any>>
var mark_dir: string


export def List(): list<dict<any>>
    return mark_list
enddef


export def Dir(): string
    return mark_dir
enddef


export def Add(items: list<dict<any>>)
    mark_list += items
    mark_list->sort()->uniq()
    mark_dir = b:dir_cwd
enddef


export def Clear()
    mark_list = []
    mark_dir = ""
enddef


export def DebugPrint()
    echo mark_list
    echo $"Mark Dir: {mark_dir}"
enddef


export def Empty(): bool
    return len(mark_list) == 0
enddef
