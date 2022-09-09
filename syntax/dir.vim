vim9script

if exists("b:current_syntax")
    finish
endif

syn match dirCwd "\%^.*$"

syn match dirStatus '\%2l^.*$' transparent contains=dirStatusSort,dirStatusHidden,dirStatusFilter,dirStatusSel
syn match dirStatusSort 'Sort by' skipwhite contained nextgroup=dirStatusSortBy
syn match dirStatusSortBy '\(name\|size\|time\) [▲▼]' skipwhite contained
syn match dirStatusHidden 'Show \zs\.\ze entries' skipwhite contained
syn match dirStatusFilter '\(Hide\|Show\) matched: \zs.\{-}\ze\( | Selected:\|$\)' skipwhite contained
syn match dirStatusSel 'Selected:' skipwhite contained nextgroup=dirStatusSelNum
syn match dirStatusSelNum '\d\+' skipwhite contained nextgroup=dirStatusSelIn
syn match dirStatusSelIn 'in' skipwhite contained nextgroup=dirStatusSelPath
syn match dirStatusSelPath '\f\+' contained

syn match dirDirectory '^[dj].*$' contains=dirPermission
syn match dirFile '^[-].*$' contains=dirPermission
syn match dirLink '^[l].*$' contains=dirPermission

syn match dirPermission '[-djl][-rwx]\{9}' transparent skipwhite contained contains=dirType nextgroup=dirOwnerGroupSizeTimeView,dirSizeTimeView,DirTimeView
syn match dirType "^[-djl]" contained nextgroup=dirPermissionUser
syn match dirPermissionUser '[-r][-w][-x]' contained nextgroup=dirPermissionGroup
syn match dirPermissionGroup '[-r][-w][-x]' contained nextgroup=dirPermissionOther
syn match dirPermissionOther '[-r][-w][-x]' contained

syn match dirOwnerGroupSizeTimeView '[[:alpha:]-_]\+\s\+[[:alpha:]-_]\+\s\+-\?\d\+\(\.\d\+\)\?[KMG]\?\s\+\d\{4}-\d\{2}-\d\{2}\s\d\d:\d\d' contained contains=dirOwnerGroup,dirSize,dirTime transparent
syn match dirSizeTimeView '-\?\d\+\(\.\d\+\)\?[KMG]\?\s\+\d\{4}-\d\{2}-\d\{2}\s\d\d:\d\d' contained contains=dirSize,dirTime transparent
syn match dirTimeView '\d\{4}-\d\{2}-\d\{2}\s\d\d:\d\d' contained contains=dirTime transparent

syn match dirOwnerGroup '[[:alpha:]-_]\+\s\+[[:alpha:]-_]\+\s\+\ze\(-\?\d\+\(\.\d\+\)\?\)' contained transparent skipwhite contains=dirOwner,dirGroup
syn match dirOwner '[[:alpha:]-_]\+' contained skipwhite
syn match dirGroup '[[:alpha:]-_]\+\ze\s\+\(-\?\d\+\)' contained skipwhite

syn match dirSize '-\?\d\+\(\.\d\+\)\?[KMG]\? ' contained contains=dirSizeMod skipwhite nextgroup=dirTime
syn match dirSizeMod '[KMG]' contained

syn match dirTime '\d\{4}-\d\{2}-\d\{2}\s\d\d:\d\d' contained skipwhite


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
