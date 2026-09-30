vim9script

var dir_history: list<any>

import autoload 'dir/setting.vim'

dir_history = setting.Load("history.json") ?? dir_history


export def Add(path: string)
    var idx = dir_history->index(path)
    if  idx > -1
        dir_history->remove(idx)
    endif
    dir_history->insert(path)
    if dir_history->len() > get(g:, "dir_history_size", 100)
        dir_history = dir_history[ : get(g:, "dir_history_size", 30) - 1]
    endif
    setting.Save("history.json", dir_history)
enddef


export def Paths(): list<string>
    return dir_history->filter((_, v) => isdirectory(v))
enddef
