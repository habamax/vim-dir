vim9script

import autoload 'dir/os.vim'


export def Load(file: string): any
    const sfiles = SettingFile(file)
        ->tuple2list()
        ->filter((_, n) => filereadable(n))
    if empty(sfiles)
        return v:none
    endif
    try
        return readfile(sfiles[0])->join()->json_decode()
    catch
        echohl Error
        echomsg v:exception
        echohl None
        return v:none
    endtry
enddef

export def Save(file: string, data: any)
    const [sfile; _] = SettingFile(file)
    try
        if !filereadable(sfile)
            fnamemodify(sfile, ':p:h')->mkdir('p')
        endif
        [json_encode(data)]->writefile(sfile)
    catch
        echohl Error
        echomsg v:exception
        echohl None
    endtry
enddef

def SettingFile(file: string): tuple<string, ...list<string>>
    return SettingDir()
        ->map((_, n) => $'{n}{os.Sep()}{file}')
        ->list2tuple()
enddef

def SettingDir(): list<string>
    if exists('g:dir_settings_dir')
        return [g:dir_settings_dir]
    endif

    var dirs: list<string>
    if has('win32')
        dirs = ['$APPDATA']
    else
        dirs = [getenv('XDG_DATA_HOME') ?? '~/.local/share', getenv('XDG_CONFIG_HOME') ?? '~/.config']
    endif

    return dirs->map((_, n) => $'{expand(n)}{os.Sep()}vim-dir')
enddef
