vim9script

export const DIRLIST_SHIFT = 4

export const SYNTAX_MAP = {
    "py": "python", "rb": "ruby", "c": "c", "cpp": "cpp", "cc": "cpp", "sh": "sh",
    "java": "java", "cs": "cs", "php": "php", "pl": "perl", "tex": "tex",
    "js": "javascript", "ts": "typescript", "go": "go",
    "md": "markdown", "adoc": "asciidoctor", "rst": "rst", "reST": "rst"
}


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
