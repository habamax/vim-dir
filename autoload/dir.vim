vim9script

import autoload 'dir/fmt.vim'
import autoload 'dir/mark.vim'
import autoload 'dir/os.vim'
import autoload 'dir/g.vim'


def GetBufnr(name: string): number
    var bufnrs = getbufinfo()->filter((_, v) => v.name == name)
    var result = -1
    if len(bufnrs) > 0
        result = bufnrs[0].bufnr
    endif
    return result
enddef


def PrintDir(dir: list<dict<any>>)
    var view = winsaveview()
    setl ma nomod noro
    sil! :%d _
    setline(1, b:dir_cwd)
    var strdir = dir->mapnew((_, v) => fmt.Dir(v))
    if len(strdir) > 0
        setline(2, ["", ""] + strdir)
    endif
    setl noma nomod ro
    winrestview(view)
enddef


def ReadDir(name: string): list<dict<any>>
    var path = resolve(name)
    # NOTE: this is still at least 3 times faster than a single readdirex call with a sort
    # to put directories first
    return readdirex(path, (v) => v.type =~ 'dir\|junction\|linkd') +
           readdirex(path, (v) => v.type =~ 'file\|link$')
enddef


def OpenBuffer(name: string): bool
    try
        silent! exe $"lcd {name->escape('%#')}"
        readdir(resolve(name), '0')
    catch
        echohl ErrorMsg
        echom v:exception
        echohl none
        return false
    endtry

    var bufname = $"dir://{name}"
    # buffer names are unreliable in :b command...
    var bufnrs = getbufinfo()->filter((_, v) => v.name == bufname)
    var bufnr = GetBufnr(bufname)
    if &hidden
        if bufnr > 0
            exe $"sil! keepj keepalt b {bufnr}"
            return false
        else
            enew
        endif
    elseif &modified && bufnr > 0
        exe $"sil! keepj keepalt sb {bufnr}"
        return false
    elseif bufnr > 0
        exe $"sil! keepj keepalt b {bufnr}"
        return false
    elseif &modified
        new
    else
        enew
    endif
    set ft=dir
    exe $"sil! keepj keepalt file {bufname}"

    return true
enddef


export def Open(name: string = '', mod: string = '', invalidate: bool = true)
    var oname = name->substitute("^dir://", "", "")
    if empty(oname) | oname = get(b:, "dir_cwd", '') | endif
    if empty(oname)
        var curbuf = expand("%")->substitute("^dir://", "", "")
        oname = isdirectory(curbuf) ? fnamemodify(curbuf, ":p") : fnamemodify(curbuf, ":p:h")
    endif
    if !isabsolutepath(oname)
        var base = get(b:, 'dir_cwd', getcwd())->trim('/\\', 2)
        oname = simplify($"{base}{os.Sep()}{oname}")
    endif
    if !isdirectory(oname) && !filereadable(oname)
        echohl Error
        echomsg $'Can not read "{oname}"!'
        echohl None
        return
    endif

    if oname =~ '.[/\\]$' && oname !~ '^\u:\\$'
        oname = oname->trim('/\', 2)
    endif

    # open using OS
    if oname =~ '\c' .. g:dir_open_ext->mapnew((_, v) => $'\%({v}\)')->join('\|')
        os.Open(oname)
        return
    endif

    if !empty(mod) | exe $"{mod}" | endif

    if isdirectory(oname)
        var focus = ""
        var new_dirbuf = GetBufnr($"dir://{oname}") == -1
        if filereadable(expand("%"))
           || exists("b:dir_cwd") && len(oname) < len(b:dir_cwd) && new_dirbuf
            # focus if Dir is opened from a buffer with
            # 1. a regular file
            # 2. another Dir and you go up the tree to a not yet opened Dir
            focus = expand("%:t")
        endif
        if OpenBuffer(oname) || invalidate || get(b:, "dir_invalidate", false)
            var dir_ls: list<dict<any>>
            try
                 dir_ls = ReadDir(oname)
                 silent! exe $"lcd {oname->escape('%#')}"
            catch
                echohl ErrorMsg
                echom v:exception
                echohl none
                return
            endtry
            b:dir_cwd = oname
            b:dir = dir_ls
            b:dir_invalidate = false
            PrintDir(b:dir)
            if invalidate && bufnr() == mark.Bufnr()
                mark.Clear()
            endif
        endif

        mark.UpdateInfo()

        if !invalidate || new_dirbuf
            if len(b:dir) > 0 && line('.') < g.DIRLIST_SHIFT
                exe $":{g.DIRLIST_SHIFT}"
            endif
            if len(b:dir) == 0
                exe $"norm! $2F{os.Sep()}l"
            elseif !empty(focus)
                if search($'\d\d:\d\d\s\+\zs{focus}', 'c') == 0
                    search($'\d\d:\d\d\s\+\zs{focus}', 'b')
                endif
            else
                norm! $
                search('\d\d:\d\d\s\+\zs', 'b', line('.'))
            endif
        endif
    else
        exe $"e {oname->escape('%#')}"
    endif
enddef
