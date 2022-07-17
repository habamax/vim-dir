vim9script

var mark_list: list<dict<any>>


export def List(): list<dict<any>>
    return mark_list
enddef


export def Add(items: list<dict<any>>)
    mark_list += items
    mark_list->sort()->uniq()
enddef


export def Clear()
    mark_list = []
enddef


export def DebugPrint()
    echo mark_list
enddef


export def Empty(): bool
    return len(mark_list) == 0
enddef
