vim9script

var bookmarks_num: dict<any> = {}

import autoload 'dir.vim'
import autoload 'dir/os.vim'
import autoload 'dir/g.vim'


def SettingFile(): string
    if has("win32")
        return $'{expand("$APPDATA")}{os.Sep()}vim-dir{os.Sep()}/bookmarks_num.json'
    else
        return $'{expand("~/.config")}{os.Sep()}vim-dir{os.Sep()}/bookmarks_num.json'
    endif
enddef


export def LoadNum()
    var sfile = SettingFile()
    if !filereadable(sfile) | return | endif
    try
        bookmarks_num = readfile(sfile)->join()->json_decode()
    catch
        echohl Error
        echomsg v:exception
        echohl None
    endtry
enddef

LoadNum()


def SaveNum()
    var sfile = SettingFile()
    try
        if !filereadable(sfile)
            mkdir(fnamemodify(sfile, ":p:h"), "p")
        endif
        [bookmarks_num->json_encode()]->writefile(sfile)
    catch
        echohl Error
        echomsg v:exception
        echohl None
    endtry
enddef


export def GoNum(n: number)
    if n < 0 || n > 9 | return | endif
    if !exists("b:dir_cwd") | return | endif
    var path = get(bookmarks_num, n, '')
    if empty(path)
        g.Echo({t: $'Bookmark {n} is not set!', hl: 'WarningMsg'})
        return
    endif
    if !isdirectory(path)
        g.Echo({t: $'Bookmark {n}:', hl: 'WarningMsg'}, ' there is no "', {t: path, hl: 'Directory'}, '"!')
        return
    endif
    dir.Open(path, '', false)
    g.Echo({t: $'Bookmark {n}:', hl: 'WarningMsg'}, ' "', {t: path, hl: 'Directory'}, '"')
enddef


export def GoNumSet(n: number)
    if n < 0 || n > 9 | return | endif
    if !exists("b:dir_cwd") | return | endif
    bookmarks_num[n] = b:dir_cwd
    SaveNum()
    g.Echo({t: $'Saving bookmark {n}:', hl: 'WarningMsg'}, ' "', {t: b:dir_cwd, hl: 'Directory'}, '"')
enddef
