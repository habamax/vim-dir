vim9script

import autoload 'dir/mark.vim'
import autoload 'dir/popup.vim'


export def Sep(): string
    return has("win32") ? '\' : '/'
enddef


def WslToWindowsPath(path: string): string
    if !exists("$WSLENV")
        return path
    endif

    if !executable('wslpath')
        return path
    endif

    var res = systemlist($"wslpath -w '{path}'")
    return empty(res) ? path : res[0]
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
        url = WslToWindowsPath(name)->escape('\\')
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
        new_name = simplify($'{getcwd()}{Sep()}{new_name}')
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


export def RenameWithPattern(name: string, pattern: string, counter: number = -1)
    var fname = fnamemodify(name, ':t:r')
    var fext = fnamemodify(name, ':e')
    if !empty(fext) | fext = $".{fext}" | endif
    var new_name = pattern->substitute('{name}', fname, 'g')
    new_name = new_name->substitute('{ext}', fext, 'g')
    if counter >= 0
        new_name = new_name->substitute('{\(\d\+\)}', '\=(submatch(1)->str2nr() + counter)', 'g')
    endif
    if empty(new_name) | return | endif
    if !isabsolutepath(new_name)
        new_name = simplify($'{getcwd()}{Sep()}{new_name}')
    endif
    if isdirectory(new_name) || filereadable(new_name)
        echo "    "
        echohl ErrorMsg
        echom $'Can not rename "{name}" to "{new_name}"!'
        echohl None
        return
    endif

    rename(name, new_name)
enddef


export def ListDirTree(name: string): list<dict<any>>
    var result = []
    var basename = fnamemodify(name, ":t")
    var path = fnamemodify(name, ":h")
    try
        result = readdirex(name, '1', {sort: 'none'})
        for elm in result
            elm.name = $"{basename}{Sep()}{elm.name}"
        endfor
        var dirs = result->copy()->filter((_, v) => v.type == 'dir')
        while !empty(dirs)
            var item = dirs->remove(-1)
            var lst = readdirex($"{path}{Sep()}{item.name}", '1', {sort: 'none'})
            for elm in lst
                elm.name = $"{item.name}{Sep()}{elm.name}"
            endfor
            var subdirs = lst->copy()->filter((_, v) => v.type == 'dir')
            dirs += subdirs
            result += lst
        endwhile
    finally
        return result
    endtry
enddef


export def Copy()
    if mark.Empty() | return | endif
    if !isdirectory(get(b:, "dir_cwd", "")) | return | endif

    var copy_cmd = "cp"
    var dest_dir = $"{b:dir_cwd}"

    if has("win32")
        copy_cmd = "copy /Y"
    endif

    var override = false
    # 1 - override all files
    # -1 - do not override anything
    var override_all = 0

    # WIP
    var file_list = mark.List()->copy()
    var dir_list = mark.List()->copy()->filter((_, v) => v.type == 'dir')
    for item in dir_list
        file_list += ListDirTree($"{mark.Dir()}{Sep()}{item.name}")
    endfor
    for item in file_list
        var src = $"{mark.Dir()}{Sep()}{item.name}"
        var dst = $"{b:dir_cwd}{Sep()}{item.name}"
        try
            if item.type == 'dir' && !isdirectory(dst)
                mkdir(dst, "p")
            else
                var file_exists = filereadable(dst)
                if file_exists && override_all == 0
                    var res = popup.Confirm(['Override existing', $'"{dst}"?'], [
                                {text: "&yes", act: 'y'},
                                {text: "&no", act: 'n'},
                                {text: "yes to &all", act: 'a'},
                                {text: "n&o to all", act: 'o'}
                            ])
                        echo res
                    if res == 0
                        override = true
                        override_all = 0
                    elseif res == 1
                        override = false
                        override_all = 0
                    elseif res == 2
                        override = true
                        override_all = 1
                    elseif res == 3
                        override = false
                        override_all = 1
                    endif
                endif
                if file_exists && override || !file_exists
                    if !isdirectory(fnamemodify(dst, ":h"))
                        mkdir(fnamemodify(dst, ":h"), "p")
                    endif
                    system($'{copy_cmd} "{src}" "{dst}"')
                endif
            endif
        catch
            echo v:exception
        endtry
    endfor
    mark.Clear()
enddef


export def CreateDir()
    var new_name = input($'Create directory: ')
    if empty(new_name) | return | endif
    if !isabsolutepath(new_name)
        new_name = simplify($'{getcwd()}{Sep()}{new_name}')
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
        output = systemlist($'tree /A "{resolve(name)}"')[3 : ]->map((_, v) => trim(v, "\r",  2))
    elseif executable("tree")
        output = systemlist($'tree -d --noreport "{resolve(name)}"')[1 : ]
    else
        output = systemlist($'stat -L "{resolve(name)}"')
    endif
    return output
enddef
