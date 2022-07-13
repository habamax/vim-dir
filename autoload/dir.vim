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
    var dirs = readdirex(path, (v) => v.type =~ 'dir\|junction\|linkd')
    var files = readdirex(path, (v) => v.type =~ 'file\|link$')
    return dirs + files
enddef


export def Open(name: string = '', mod: string = '')
    var oname = expand(name->substitute("^dir://", "", ""), 1)
    if empty(oname) | oname = get(b:, "dir_cwd", '') | endif
    if empty(oname)
        oname = isdirectory(name) ? fnamemodify(name, ":p") : fnamemodify(name, "%:p:h")
    endif
    oname = oname->substitute('\', '/', 'g')
    if !isabsolutepath(oname) | oname = simplify($"{getcwd()}/{oname}") | endif
    if !isdirectory(oname) && !filereadable(oname) | return | endif
    if oname =~ './$' && oname !~ '^\u:/$' | oname = oname->trim('/', 2) | endif
    oname = oname->escape('%')

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

        var new_bufname = $"dir://{oname}"
        if &hidden
            if new_bufname->bufexists()
                exe $"sil! keepj keepalt b {new_bufname}"
            else
                enew
            endif
        elseif &modified && new_bufname->bufexists()
            exe $"sil! keepj keepalt sb {new_bufname}"
        elseif new_bufname->bufexists()
            exe $"sil! keepj keepalt b {new_bufname}"
        elseif &modified
            new
        else
            enew
        endif
        set ft=dir
        set buftype=acwrite
        set bufhidden=unload
        set nobuflisted
        set noswapfile

        exe $"sil! keepj keepalt file {new_bufname}"
        exe $"lcd {oname}"
        b:dir = ReadDir(oname)
        b:dir_cwd = oname
        PrintDir(b:dir)
        norm! j
        norm! $2F/l
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
        exe $"e {oname}"
    endif
enddef
