vim9script

# {
#   named: {'bookmark name': '/some/path', 'another name': '/other/path'},
#   numbered: {0: '/some/path', 1: '/some/other/path}
# }
var bookmarks: dict<any> = {named: {}, numbered: {}}

import autoload 'dir.vim'
import autoload 'dir/g.vim'
import autoload 'dir/os.vim'


def SettingFile(): string
    if has("win32")
        return $'{expand("$APPDATA")}{os.Sep()}vim-dir{os.Sep()}/bookmarks.json'
    else
        return $'{expand("~/.config")}{os.Sep()}vim-dir{os.Sep()}/bookmarks.json'
    endif
enddef


export def Load()
    var sfile = SettingFile()
    if !filereadable(sfile) | return | endif
    try
        bookmarks = readfile(sfile)->join()->json_decode()
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
        [bookmarks->json_encode()]->writefile(sfile)
    catch
        echohl Error
        echomsg v:exception
        echohl None
    endtry
enddef


export def JumpNum(n: number)
    if n < 0 || n > 9 | return | endif
    if !exists("b:dir_cwd") | return | endif
    var num_bookmarks = get(bookmarks, 'numbered', {})
    var path = get(num_bookmarks, n, '')
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


export def SetNum(n: number)
    if n < 0 || n > 9 | return | endif
    if !exists("b:dir_cwd") | return | endif
    bookmarks['numbered'][n] = b:dir_cwd
    Save()
    g.Echo({t: $'Saving bookmark {n}:', hl: 'WarningMsg'}, ' "', {t: b:dir_cwd, hl: 'Directory'}, '"')
enddef


export def Set(name: string, path: string)
    if empty(path)
        g.Echo({t: $'Bookmark "{name}" has no path!', hl: 'WarningMsg'})
        return
    endif

    bookmarks.named[name] = path
    g.Echo({t: $'Saving bookmark "{name}":', hl: 'WarningMsg'}, ' "', {t: b:dir_cwd, hl: 'Directory'}, '"')
    Save()
enddef


export def Jump(name: string)
    var name_bookmarks = get(bookmarks, 'named', {})
    var path = get(name_bookmarks, name, '')
    if empty(path)
        g.Echo({t: $'Bookmark "{name}" is not set!', hl: 'WarningMsg'})
        return
    endif
    if !isdirectory(path)
        g.Echo({t: $'Bookmark "{name}":', hl: 'WarningMsg'}, ' there is no "', {t: path, hl: 'Directory'}, '"!')
        return
    endif
    dir.Open(path, '', false)
enddef


export def Names(): list<string>
    return bookmarks.named->keys()
enddef


export def NamesAndPaths(): list<list<any>>
    return bookmarks.named->items()
enddef



export def Exists(name: string): bool
    return bookmarks.named->keys()->index(name) > -1
enddef


export def Get(name: string): string
    return bookmarks.named[name]
enddef
