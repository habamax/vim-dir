vim9script

import autoload 'dir/g.vim'
import autoload 'dir/fmt.vim'
import autoload 'dir/mark.vim'
import autoload 'dir/os.vim'
import autoload 'dir/sort.vim' as dsort
import autoload 'dir/history.vim'



export def UpdateStatusInfo()
    for buf_info in g.DirBuffers()
        var status = []
        setbufvar(buf_info.bufnr, '&modifiable', 1)
        setbufvar(buf_info.bufnr, '&readonly', 0)

        var fltr = getbufvar(buf_info.bufnr, 'dir_filter', '')
        var fltr_bang = getbufvar(buf_info.bufnr, 'dir_filter_bang', '')
        var fltr_msg = ""
        if !empty(fltr)
            if empty(fltr_bang)
                fltr_msg = "Show matched: "
            else
                fltr_msg = "Hide matched: "
            endif
            fltr_msg ..= fltr
        endif

        status->add(dsort.Info(buf_info.bufnr))
        status->add(get(g:, "dir_show_hidden", true) ? "Show .hidden" : "")
        status->add(fltr_msg)
        status->add(mark.Info(buf_info.bufnr))
        status->filter((_, v) => !v->empty())


        setbufline(buf_info.bufnr, 2, join(status, ' | '))

        setbufvar(buf_info.bufnr, '&modified', 0)
        setbufvar(buf_info.bufnr, '&modifiable', 0)
        setbufvar(buf_info.bufnr, '&readonly', 1)
    endfor
enddef


# default sort is by name asc
# we shouldn't sort if no other sorting was done
def NeedSorting(): bool
    if get(b:, "dir_sort_by", "name") == "name" && !get(b:, "dir_sort_desc", false)
        return false
    else
        return true
    endif
enddef


export def SortDir(dir: list<dict<any>>)
    b:dir_sort_by = get(b:, "dir_sort_by") ?? get(g:, "dir_sort_by", "name")
    b:dir_sort_desc = get(b:, "dir_sort_desc") ?? get(g:, "dir_sort_desc", false)
    if b:dir_sort_by == 'time'
        dsort.ByTime(dir, b:dir_sort_desc)
    elseif b:dir_sort_by == 'size'
        dsort.BySize(dir, b:dir_sort_desc)
    elseif b:dir_sort_by == 'name'
        dsort.ByName(dir, b:dir_sort_desc)
    elseif b:dir_sort_by == 'extension'
        dsort.ByExtension(dir, b:dir_sort_desc)
    endif
enddef


export def FilterDir(dir: list<dict<any>>)
    b:dir_show_hidden = get(g:, "dir_show_hidden", true)
    if !b:dir_show_hidden
        dir->filter((_, v) => v.name !~ '^\.')
    endif

    var fltr = get(b:, 'dir_filter', '')
    if empty(fltr) | return | endif
    if empty(get(b:, 'dir_filter_bang', ''))
        dir->filter((_, v) => v.name =~ fltr)
    else
        dir->filter((_, v) => v.name !~ fltr)
    endif
enddef


export def PrintDir(dir: list<dict<any>>)
    # calc max width of user/group/size
    var user_width: number = 1
    var group_width: number = 1
    var size_width: number = 1
    for elt in dir
        if len(elt.user) > user_width
            user_width = len(elt.user)
        endif
        if len(elt.group) > group_width
            group_width = len(elt.group)
        endif
        var cur_size = len(fmt.Size(elt))
        if cur_size > size_width
            size_width = cur_size
        endif
    endfor
    fmt.Setup(user_width, group_width, size_width)

    var view = winsaveview()
    setl ma nomod noro
    sil! keepj :%d _
    keepj setline(1, b:dir_cwd)
    var dir_text = dir->mapnew((_, v) => fmt.Dir(v))
    if len(dir_text) > 0
        keepj setline(2, ["", ""] + dir_text)
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

    var result = true
    var bufname = $"dir://{name}"
    var bufnr = g.GetBufnr(bufname)
    if &hidden
        if bufnr > 0
            exe $"sil! keepalt b {bufnr}"
            result = false
        elseif !isdirectory(bufname())
            enew
        endif
    elseif &modified && bufnr > 0
        exe $"sil! keepalt sb {bufnr}"
        result = false
    elseif bufnr > 0
        exe $"sil! keepalt b {bufnr}"
        result = false
    elseif &modified
        new
    elseif !isdirectory(bufname())
        enew
    endif
    exe $"sil! keepalt file {bufname}"
    set ft=dir

    return result
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
        oname = getcwd()
    endif

    if oname =~ '.[/\\]$' && oname !~ '^\u:\\$'
        oname = oname->trim('/\', 2)
    endif

    # open using OS
    if g:dir_open_os->index(fnamemodify(oname, ":e"), 0, true) != -1
        os.Open(oname)
        history.Add(b:dir_cwd)
        return
    endif

    var dir_cwd = get(b:, "dir_cwd", "")
    if !empty(mod) | exe $"{mod}" | endif

    if isdirectory(oname)
        var focus = ""
        var new_dirbuf = g.GetBufnr($"dir://{oname}") == -1
        if filereadable(expand("%"))
           || exists("b:dir_cwd") && len(oname) < len(b:dir_cwd)
            # focus if Dir is opened from a buffer with
            # 1. a regular file
            # 2. another Dir and you go up the tree to a not yet opened Dir
            focus = expand("%:t")
        endif
        if OpenBuffer(oname) || invalidate
                             || get(b:, "dir_invalidate", false)
                             || (get(b:, "dir_show_hidden", true) != get(g:, "dir_show_hidden", true))
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
            FilterDir(b:dir)
            if NeedSorting()
                SortDir(b:dir)
            endif
            PrintDir(b:dir)
        endif

        UpdateStatusInfo()
        mark.RefreshVisual()

        if !invalidate || new_dirbuf
            if len(b:dir) == 0
                exe $"norm! $2F{os.Sep()}l"
            else
                if !empty(focus)
                    var idx = b:dir->indexof((_, val) => val.name == focus)
                    if idx > -1
                        exe $":{idx + g.DIRLIST_SHIFT}"
                    endif
                elseif line('.') < g.DIRLIST_SHIFT
                    exe $":{g.DIRLIST_SHIFT}"
                endif
                norm! $
                search('\v((\d\d:\d\d\s+)|([djl-][rwx-]{9}\s+)|^)\zs', 'b', line('.'))
            endif
        endif
    else
        if !empty(dir_cwd)
            history.Add(dir_cwd)
        endif
        exe $"e {oname->escape('%#')}"
    endif
enddef
