vim9script


def WslToWindowsPath(path: string): string
    if !exists("$WSLENV")
        return path
    endif

    if !executable('wslpath')
        return path
    endif

    var res = systemlist($"wslpath -w '{path}'")
    if !empty(res)
        return substitute(res[0], '\\', '/', 'g')
    else
        return path
    endif
enddef


export def Open(name: string)
    var url = name
    var cmd = ''
    if executable('cmd.exe')
        cmd = 'cmd.exe /C start ""'
    elseif executable('xdg-open')
        cmd = "xdg-open"
    elseif executable('open')
        cmd = "open"
    else
        echohl Error
        echomsg "Can't find proper opener for an URL!"
        echohl None
        return
    endif
    var job_opts = {}
    if exists("$WSLENV")
        job_opts.cwd = "/mnt/c/"
        url = WslToWindowsPath(name)
    endif
    job_start(printf('%s "%s"', cmd, url), job_opts)
enddef


export def Delete(name: string)
    if isdirectory(name)
        delete(name, "rf")
    else
        delete(name)
    endif
enddef


export def Rename(name: string)
    var old_name = fnamemodify(name, ":t")
    var new_name = input($'Rename "{old_name}" to: ', old_name, "file")
    if empty(new_name) | return | endif
    if new_name == old_name | return | endif
    if !isabsolutepath(new_name)
        new_name = simplify($'{getcwd()}/{new_name}')
    endif
    if isdirectory(new_name) || filereadable(new_name)
        echo "    "
        echohl ErrorMsg
        echo "Can't rename to existing file or directory!"
        echohl None
        return
    endif

    rename(name, new_name)
enddef


export def CreateDir()
    var new_name = input($'Create directory: ')
    if empty(new_name) | return | endif
    if !isabsolutepath(new_name)
        new_name = simplify($'{getcwd()}/{new_name}')
    endif
    if isdirectory(new_name) || filereadable(new_name)
        echo "    "
        echohl ErrorMsg
        echo "File or Directory exists!"
        echohl None
        return
    endif

    mkdir(new_name, "p")
enddef


export def DirInfo(name: string): list<string>
    var output = []
    if has("win32")
        output = systemlist($'tree /A "{resolve(name)}"')->map((_, v) => trim(v, "\r",  2))
    elseif executable("tree")
        output = systemlist($'stat -L "{resolve(name)}"') + [""] + systemlist($'tree -d "{resolve(name)}"')
    else
        output = systemlist($'stat -L "{resolve(name)}"')
    endif
    return output
enddef
