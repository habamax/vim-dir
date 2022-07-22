vim9script

export const DIRLIST_SHIFT = 4


export def OtherDirBuffers(): list<dict<any>>
    return getbufinfo()->filter((_, v) => v.name =~ '^dir://' && bufnr() != v.bufnr)
enddef


export def DirBuffers(): list<dict<any>>
    return getbufinfo()->filter((_, v) => v.name =~ '^dir://')
enddef


