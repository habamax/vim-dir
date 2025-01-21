vim9script

var dir_history: list<any>

import autoload 'dir/g.vim'
import autoload 'dir/os.vim'


def SettingFile(): string
    if has("win32")
        return $'{expand("$APPDATA")}{os.Sep()}vim-dir{os.Sep()}/history.json'
    else
        return $'{expand("~/.config")}{os.Sep()}vim-dir{os.Sep()}/history.json'
    endif
enddef


export def Load()
    var sfile = SettingFile()
    if !filereadable(sfile) | return | endif
    try
        dir_history = readfile(sfile)->join()->json_decode()
    catch
        echohl Error
        echomsg v:exception
        echohl None
    endtry
enddef

Load()


def Save()
    var sfile = SettingFile()
    try
        if !filereadable(sfile)
            mkdir(fnamemodify(sfile, ":p:h"), "p")
        endif
        [dir_history->json_encode()]->writefile(sfile)
    catch
        echohl Error
        echomsg v:exception
        echohl None
    endtry
enddef


export def Add(path: string)
    var idx = dir_history->index(path)
    if  idx > -1
        dir_history->remove(idx)
    endif
    dir_history->insert(path)
    if dir_history->len() > get(g:, "dir_history_size", 100)
        dir_history = dir_history[ : get(g:, "dir_history_size", 30) - 1]
    endif
    Save()
enddef


export def Paths(): list<string>
    return dir_history->filter((_, v) => isdirectory(v))
enddef
