vim9script

export const DIRLIST_SHIFT = 4

export const PREVIEW_LINES = 1000

export const PREVIEW_SYNTAX_MAP = [
    ["vim", '\.\?\(g\?vimrc\|vim\)$'],
    ["zsh", '\.zshrc$'], ["sh", '\.\(\(bash\(rc\|_profile\)\)\|\(sh\)\)$'],
    ["tmux", '\.tmux\.conf$'], ["xdefaults", '\.X\(resources\|defaults\)$'],
    ["python", '\.py$'], ["ruby", '\.rb$'], ["php", '\.php$'], ["pl", '\.pl$'],
    ["c", '\.[ch]$'], ["cpp", '\.\(cpp\|cc\)$'], ["java", '\.java$'], ["cs", '\.cs$'], ["go", '\.go$'],
    ["gdscript", '\.gd$'], ["gdresource", '\.t\%(scn\|res\)$'], ["gdshader", '\.\%(gd\)\?shader$'],
    ["javascript", '\.js$'], ["typescript", '\.ts$'], ["sql", '\.sql$'], ["lua", '\.lua$'],
    ["html", '\.\(html\|htm\)$'], ["xml", '\.xml$'], ["json", '\.json'], ["conf", '\.conf$'],
    ["markdown", '\.md$'], ["asciidoctor", '\.adoc$'], ["rst", '\.\(rst\|rest\|txt\)$'], ["tex", '\.tex$']
]


export def IsFile(item: dict<any>): bool
    return item.type == 'file' || item.type == 'link'
enddef


export def OtherDirBuffers(): list<dict<any>>
    return getbufinfo()->filter((_, v) => v.name =~ '^dir://' && bufnr() != v.bufnr)
enddef


export def DirBuffers(): list<dict<any>>
    return getbufinfo()->filter((_, v) => v.name =~ '^dir://')
enddef


export def GetBufnr(name: string): number
    var bufnrs = getbufinfo()->filter((_, v) => v.name == name)
    var result = -1
    if len(bufnrs) > 0
        result = bufnrs[0].bufnr
    endif
    return result
enddef


export def Echo(...items: list<any>)
    for item in items
        if type(item) == v:t_dict && has_key(item, 't') && has_key(item, 'hl')
            exe $'echohl {item.hl}'
            echon item.t
        else
            echohl None
            echon item
        endif
    endfor
    echohl None
enddef
