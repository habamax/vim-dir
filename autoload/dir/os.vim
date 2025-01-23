vim9script

import autoload 'dir/mark.vim'
import autoload 'dir/popup.vim'
import autoload 'dir/g.vim'

export def Sep(escape: bool = false): string
    if escape
        return has("win32") ? '\\' : '/'
    else
        return has("win32") ? '\' : '/'
    endif
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
        url = WslToWindowsPath(name)->escape('\')
    endif
    if $DESKTOP_SESSION =~ 'plasma\(wayland\)\?'
        system(printf('%s "%s" &', cmd, url))
    else
        job_start(printf('%s "%s"', cmd, url), job_opts)
    endif
enddef

export def Delete(name: string)
    try
        if isdirectory(name)
            delete(name, "rf")
        else
            delete(name)
        endif
    catch
        echohl ErrorMsg
        echom v:exception
        echohl None
    finally
        mark.Clear()
    endtry
enddef

export def Rename(name: string)
    var old_name = fnamemodify(name, ":t")
    var new_name = input($'Rename "{old_name}" to: ', old_name, "file")
    if empty(new_name) | return | endif
    if new_name == old_name | return | endif
    if !isabsolutepath(new_name)
        new_name = simplify($'{b:dir_cwd}{Sep()}{new_name}')
    endif
    if isdirectory(new_name) || filereadable(new_name)
        echohl ErrorMsg
        echo "Can't rename to existing file or directory!"
        echohl None
        return
    endif

    try
        rename(name, new_name)
    catch
        echohl ErrorMsg
        echom v:exception
        echohl None
    finally
        mark.Clear()
    endtry
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
        new_name = simplify($'{b:dir_cwd}{Sep()}{new_name}')
    endif
    if isdirectory(new_name) || filereadable(new_name)
        echohl ErrorMsg
        echom $'Can not rename "{name}" to "{new_name}"!'
        echohl None
        return
    endif

    try
        rename(name, new_name)
    catch
        echohl ErrorMsg
        echom v:exception
        echohl None
    finally
        mark.Clear()
    endtry
enddef

export def ListDirTree(name: string): list<dict<any>>
    var result = []
    var basename = fnamemodify(name, ":t")
    var path = fnamemodify(name, ":h")
    try
        result = readdirex(resolve(name), '1', {sort: 'none'})
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

# XXX: explore jobs here...
export def Copy()
    if mark.IsEmpty() | return | endif
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

    var file_list = mark.List()->copy()
    var dir_list = mark.List()->copy()->filter((_, v) => v.type =~ 'dir\|linkd\|junction')
    for item in dir_list
        file_list += ListDirTree($"{mark.Dir()}{Sep()}{item.name}")
    endfor
    for item in file_list
        var src = $"{mark.Dir()}{Sep()}{item.name}"
        var dst = $"{b:dir_cwd}{Sep()}{item.name}"
        try
            if item.type =~ 'dir\|linkd\|junction' && !isdirectory(dst)
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
                    else
                        override = false
                        override_all = 0
                    endif
                endif
                if file_exists && override || !file_exists
                    if !isdirectory(fnamemodify(dst, ":h"))
                        mkdir(fnamemodify(dst, ":h"), "p")
                    endif
                    system($'{copy_cmd} "{resolve(src)}" "{dst}"')
                endif
            endif
        catch
            echo v:exception
        endtry
    endfor
    mark.Clear()
enddef

export def Duplicate()
    if mark.IsEmpty() | return | endif
    if !isdirectory(get(b:, "dir_cwd", "")) | return | endif

    var copy_cmd = "cp -R"
    var copy_dir_cmd = "cp -R"
    var dest_dir = $"{b:dir_cwd}"

    if has("win32")
        copy_cmd = "copy /Y"
        copy_dir_cmd = "xcopy /EIH"
    endif

    for item in mark.List()
        var src = $"{mark.Dir()}{Sep()}{item.name}"
        var dst = $"{b:dir_cwd}{Sep()}{GetDuplicateName(item.name)}"
        try
            if item.type == 'dir'
                system($'{copy_dir_cmd} "{resolve(src)}" "{dst}"')
            else
                system($'{copy_cmd} "{resolve(src)}" "{dst}"')
            endif
        catch
            echo v:exception
        endtry
    endfor
    mark.Clear()
enddef

# XXX: explore jobs here...
export def Move()
    if mark.IsEmpty() | return | endif
    if !isdirectory(get(b:, "dir_cwd", "")) | return | endif

    var move_cmd = "mv"
    var dest_dir = $"{b:dir_cwd}"

    if has("win32")
        move_cmd = "move /Y"
    endif

    var override = false
    # 1 - override all files
    # -1 - do not override anything
    var override_all = 0

    var file_list = mark.List()->copy()
    var dir_list = mark.List()->copy()->filter((_, v) => v.type =~ 'dir\|linkd\|junction')
    for item in dir_list
        file_list += ListDirTree($"{mark.Dir()}{Sep()}{item.name}")
    endfor
    for item in file_list
        var src = $"{mark.Dir()}{Sep()}{item.name}"
        var dst = $"{b:dir_cwd}{Sep()}{item.name}"
        try
            if item.type =~ 'dir\|linkd\|junction' && !isdirectory(dst)
                mkdir(dst, "p")
            elseif !isdirectory(src)
                var file_exists = filereadable(dst)
                if file_exists && override_all == 0
                    var res = popup.Confirm(['Override existing', $'"{dst}"?'], [
                                {text: "&yes", act: 'y'},
                                {text: "&no", act: 'n'},
                                {text: "yes to &all", act: 'a'},
                                {text: "n&o to all", act: 'o'}
                            ])
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
                    else
                        override = false
                        override_all = 0
                    endif
                endif
                if file_exists && override || !file_exists
                    if !isdirectory(fnamemodify(dst, ":h"))
                        mkdir(fnamemodify(dst, ":h"), "p")
                    endif
                    system($'{move_cmd} "{resolve(src)}" "{dst}"')
                endif
            endif
        catch
            echo v:exception
        endtry
    endfor
    for item_dir in dir_list
        Delete($"{mark.Dir()}{Sep()}{item_dir.name}")
    endfor
    for buf_info in g.OtherDirBuffers()
        setbufvar(buf_info.bufnr, "dir_invalidate", true)
    endfor
    mark.Clear()
enddef

export def CreateDir(name: string): bool
    if isdirectory(name) || filereadable(name)
        echo "    "
        echohl ErrorMsg
        echo "File or Directory exists!"
        echohl None
        return false
    endif

    try
        mkdir(name, "p")
        return true
    catch
        echohl ErrorMsg
        echom v:exception
        echohl None
    endtry
    return false
enddef

export def CompressGzip(arch_name: string, items: list<any>): bool
    if isdirectory(arch_name) || filereadable(arch_name)
        echo "    "
        echohl ErrorMsg
        echo $"Directory or file '{arch_name}' exists!"
        echohl None
        return false
    endif

    try
        exe "lcd" b:dir_cwd
        # XXX: should only be available if tar is present
        var cmd = $'tar -czvf "{arch_name}"'
        for item in items
            cmd ..= $' "{item.name}"'
        endfor
        system(cmd)
        return true
    catch
        echohl ErrorMsg
        echom v:exception
        echohl None
    finally
        lcd -
    endtry
    return false
enddef

export def CompressZip(arch_name: string, items: list<any>): bool
    if isdirectory(arch_name) || filereadable(arch_name)
        echo "    "
        echohl ErrorMsg
        echo $"Directory or file '{arch_name}' exists!"
        echohl None
        return false
    endif

    try
        exe "lcd" b:dir_cwd
        # XXX: should only be available if zip is present
        var cmd = $'zip -r "{arch_name}"'
        for item in items
            var name = item.name
            if item.type == 'dir'
                name ..= "/"
            endif
            cmd ..= $' "{name}"'
        endfor
        system(cmd)
        return true
    catch
        echohl ErrorMsg
        echom v:exception
        echohl None
    finally
        lcd -
    endtry
    return false
enddef

export def ExtractArch(arch_name: string, path: string = '.'): bool
    if !filereadable(arch_name)
        echohl ErrorMsg
        echo $"'{arch_name}' doesn't exists!"
        echohl None
        return false
    endif

    var cmd: string
    try
        # XXX: should only be available if unzip/tar is present
        if arch_name =~ '\.zip$'
            cmd = $'unzip "{arch_name}" -d "{path}"'
        elseif arch_name =~ '\.[gx]z$'
            if path !~ '^\.\.\?/\?\s*$'
                mkdir(path, "p")
            endif
            cmd = $'tar -xf "{arch_name}" --directory "{path}"'
        endif
        if !cmd->empty()
            system(cmd)
            return true
        endif
    catch
        echohl ErrorMsg
        echom v:exception
        echohl None
    endtry
    return false
enddef

export def DirInfo(name: string): list<string>
    var output = []
    if executable('du')
        output = ["Size: " .. system($'du -sh "{resolve(name)}"')->matchstr('^\S\+')]
        output += [""]
    endif
    if executable('tree')
        if has("win32")
            output += systemlist($'tree /A "{resolve(name)}"')->mapnew((_, elem) => elem->trim("\r", 2))
        else
            output += systemlist($'tree "{resolve(name)}"')
        endif
    endif
    return output
enddef

def GetDuplicateName(name: string): string
    var ext = fnamemodify(name, ":e")
    if !empty(ext) | ext = "." .. ext | endif
    var base = fnamemodify(name, ":r")
    var files = readdirex(b:dir_cwd, (e) => e.name =~ $'^{escape(base, ".~$")}__\d\+{ext}', {sort: "none"})
    var idx = (files->mapnew((_, v) => v.name->matchstr($'^{escape(base, ".~$")}__\zs\d\+{ext}')->str2nr())->max() ?? 0) + 1
    return $"{base}__{idx}{ext}"
enddef
