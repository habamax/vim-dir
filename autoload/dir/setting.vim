vim9script

import autoload 'dir/os.vim'


export def Load(file: string): any
    const sfile = SettingFile(file)
    if !filereadable(sfile)
        return v:none
    endif
    try
        return readfile(sfile)->join()->json_decode()
    catch
        echohl Error
        echomsg v:exception
        echohl None
        return v:none
    endtry
enddef

export def Save(file: string, data: any)
    const sfile = SettingFile(file)
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

def SettingFile(file: string): string
    return $'{SettingDir()}{os.Sep()}{file}'
enddef

def SettingDir(): string
    if exists('g:dir_settings_dir')
        return g:dir_settings_dir
    endif

    var dir: string
    if has('win32')
        dir = expand('$APPDATA')
    else
        dir = expand(getenv('XDG_CONFIG_HOME') ?? '~/.config')
    endif

    return $'{dir}{os.Sep()}vim-dir'
enddef
