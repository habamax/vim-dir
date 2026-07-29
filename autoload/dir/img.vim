vim9script

var img_exe: string
if executable('magick')
    img_exe = 'magick'
elseif executable('gm')
    img_exe = 'gm'
endif

const MAX_WIDTH = 1920
const MAX_HEIGHT = 1080

export def Info(path: string): dict<any>
    if empty(img_exe)
        return {}
    endif

    var img_dim = []
    img_dim = split(system($'{img_exe} identify -format "%w %h" ' .. shellescape(path)))
    if v:shell_error != 0
        return {}
    endif

    var [w, h] = [str2nr(img_dim[0]), str2nr(img_dim[1])]
    var resized_path = ''
    if w > MAX_WIDTH || h > MAX_HEIGHT
        resized_path = tempname()
        system($'{img_exe} {shellescape(path)} -resize "{MAX_WIDTH}x{MAX_HEIGHT}>" {resized_path}')
        if v:shell_error != 0
            return {}
        endif
        img_dim = split(system($'{img_exe} identify -format "%w %h" ' .. shellescape(resized_path)))
        [w, h] = [str2nr(img_dim[0]), str2nr(img_dim[1])]
    endif

    var tmpname = tempname()
    system($'{img_exe} convert {shellescape(resized_path ?? path)} -depth 8 rgb:{tmpname}')
    if v:shell_error != 0
        return {}
    else
        return {
            data: readblob(tmpname),
            width: w,
            height: h
        }
    endif
enddef
