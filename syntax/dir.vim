vim9script

if exists("b:current_syntax")
    finish
endif

syn match dirCwd "\%^.*$"

syn match dirStatus '\%2l^.*$' transparent contains=dirStatusSort,dirStatusHidden,dirStatusFilter,dirStatusSel
syn match dirStatusSort 'Sort by' skipwhite contained nextgroup=dirStatusSortBy
syn match dirStatusSortBy '\(name\|size\|time\) [▲▼]' skipwhite contained
syn match dirStatusHidden 'Show \zs\.\ze entries' skipwhite contained
syn match dirStatusFilter '\(Hide\|Show\) matched: \zs.\{-}\ze\(|\|$\)' skipwhite contained
syn match dirStatusSel 'Selected:' skipwhite contained nextgroup=dirStatusSelNum
syn match dirStatusSelNum '\d\+' skipwhite contained nextgroup=dirStatusSelPath
syn match dirStatusSelPath 'in \f\+' contained

syn match dirDirectory "^[dj].*$" contains=dirType
syn match dirFile "^[-].*$" contains=dirType
syn match dirLink "^[l].*$" contains=dirType

syn match dirType "^[-djl]" contained nextgroup=dirPermissionUser
syn match dirPermissionUser "[-r][-w][-x]" contained nextgroup=dirPermissionGroup
syn match dirPermissionGroup "[-r][-w][-x]" contained nextgroup=dirPermissionOther
if has("win32")
    syn match dirPermissionOther "[-r][-w][-x]" contained nextgroup=dirSize skipwhite
else
    syn match dirPermissionOther "[-r][-w][-x]" contained nextgroup=dirOwner skipwhite
    syn match dirOwner "\S\+" contained nextgroup=dirGroup skipwhite
    syn match dirGroup "\S\+" contained nextgroup=dirSize skipwhite
endif
syn match dirSize "\d\+[KMG]\?" contained nextgroup=dirTime contains=dirSizeMod skipwhite
syn match dirSizeMod "[KMG]" contained
syn match dirTime "\d\{4}-\d\{2}-\d\{2}\s\d\d:\d\d" contained nextgroup=dirName skipwhite
syn match dirName ".*$" contained transparent


hi def link dirCwd Title
hi def link dirType Type
hi def link dirPermissionUser Constant
hi def link dirPermissionGroup PreProc
hi def link dirPermissionOther Special
hi def link dirOwner Identifier
hi def link dirGroup Identifier
hi def link dirSize Constant
hi def link dirSizeMod Type
hi def link dirTime PreProc
hi def link dirDirectory Directory
hi def link dirLink Type
hi def link dirStatusSelNum Constant
hi def link dirStatusSelPath Directory
hi def link dirStatusSortBy Constant
hi def link dirStatusHidden Constant
hi def link dirStatusFilter Constant
hi def link dirMark Todo

b:current_syntax = "dir"
