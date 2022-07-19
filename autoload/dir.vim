vim9script

import autoload 'dir/fmt.vim'
import autoload 'dir/os.vim'


def PrintDir(dir: list<dict<any>>)
    setl ma nomod noro
    sil! :%d _
    setline(1, b:dir_cwd)
    var strdir = dir->mapnew((_, v) => fmt.Dir(v))
    if len(strdir) > 0
        setline(2, [""] + strdir)
    endif
    setl noma nomod ro
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
        exe $"lcd {name->escape('%#')}"
    catch
        echohl ErrorMsg
        echom v:exception
        echohl none
        return false
    endtry

    var bufname = $"dir://{name}"
    if &hidden
        if bufname->bufexists()
            exe $"sil! keepj keepalt b {bufname}"
            return false
        else
            enew
        endif
    elseif &modified && bufname->bufexists()
        exe $"sil! keepj keepalt sb {bufname}"
        return false
    elseif bufname->bufexists()
        exe $"sil! keepj keepalt b {bufname}"
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
    if !isabsolutepath(oname) | oname = simplify($"{get(b:, 'dir_cwd', getcwd())}{os.Sep()}{oname}") | endif
    if !isdirectory(oname) && !filereadable(oname) | return | endif

    if oname =~ '[/\\]$' && oname !~ '^\u:\$'
        oname = oname->trim('/\', 2) 
    endif

    # open using OS
    if oname =~ '\c' .. g:dir_open_ext->mapnew((_, v) => $'\%({v}\)')->join('\|')
        os.Open(oname)
        return
    endif

    if !empty(mod) | exe $"{mod}" | endif

    if isdirectory(oname)
        var maybe_focus = ""
        if (&ft != 'dir' && filereadable(expand("%"))) ||
            (&ft == 'dir' && len(oname) < len(get(b:, "dir_cwd", "")) && isdirectory($"{oname}/{expand('%:t')}"))
            maybe_focus = expand("%:t")
        endif

        if OpenBuffer(oname) || invalidate
            var dir_ls: list<dict<any>>
            try
                 dir_ls = ReadDir(oname)
                 exe $"lcd {oname->escape('%#')}"
            catch
                echohl ErrorMsg
                echom v:exception
                echohl none
                return
            endtry
            b:dir_cwd = oname
            b:dir = dir_ls
            PrintDir(b:dir)
            norm! j
            exe $"norm! $2F{os.Sep()}l"
        endif

        var focus = ''
        if empty(maybe_focus)
            if len(b:dir) > 0
                focus = b:dir[0].name
            endif
        else
            focus = maybe_focus
        endif
        search('\s\zs' .. escape(focus, '~$.') .. '\($\| ->\)')
    else
        exe $"e {oname->escape('%#')}"
    endif
enddef
