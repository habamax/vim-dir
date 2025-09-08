vim9script

if exists("b:current_syntax")
    finish
endif

syn match dirStatus '\%2l^.*$' transparent contains=dirStatusSort,dirStatusHidden,dirStatusFilter,dirStatusSel
syn match dirStatusSort 'Sort by' skipwhite contained nextgroup=dirStatusSortBy
syn match dirStatusSortBy '\(name\|size\|time\|extension\) [▲▼]' skipwhite contained
syn match dirStatusHidden 'Show \zs\.hidden' skipwhite contained
syn match dirStatusFilter '\(Hide\|Show\) matched: \zs.\{-}\ze\( | Selected:\|$\)' skipwhite contained
syn match dirStatusSel 'Selected:' skipwhite contained nextgroup=dirStatusSelNum
syn match dirStatusSelNum '\d\+' skipwhite contained nextgroup=dirStatusSelIn
syn match dirStatusSelIn 'in' skipwhite contained nextgroup=dirStatusSelPath
syn match dirStatusSelPath '\f\+' contained

syn match dirPermission '[-djl][-rwx]\{9}' transparent contains=dirType
syn match dirType "^[-djl]" contained nextgroup=dirPermissionUser
syn match dirPermissionUser '[-r][-w][-x]' contained nextgroup=dirPermissionGroup
syn match dirPermissionGroup '[-r][-w][-x]' contained nextgroup=dirPermissionOther
syn match dirPermissionOther '[-r][-w][-x]' contained

syn match dirOwnerGroup '\(^[-djl][-rwx]\{9}\s\)\@<=\a[[:alpha:]-_]*\s\+\a[[:alpha:]-_]*\ze\s' transparent contains=dirOwner,dirGroup
syn match dirOwner '\a[[:alpha:]-_]*' contained skipwhite
syn match dirGroup '\a[[:alpha:]-_]*' contained

syn match dirSize '-\?\d\+\(\.\d\+\)\?[KMG]\? \ze\d\{4}-\d\{2}-\d\{2}\s\d\d:\d\d' contains=dirSizeMod skipwhite nextgroup=dirTime
syn match dirSizeMod '[KMG]' contained

syn match dirTime '\d\{4}-\d\{2}-\d\{2}\s\d\d:\d\d'

syn match dirDirectory '\(^\|\s\)[\/].\{-}\ze\($\| ->\)'
syn match dirLink '-> .*'

syn match dirCwd "\%^.*$"


hi def link dirCwd Directory
hi def link dirType Statement
hi def link dirPermissionUser Type
hi def link dirPermissionGroup String
hi def link dirPermissionOther Special
hi def link dirOwner Comment
hi def link dirGroup Comment
hi def link dirSize Constant
hi def link dirSizeMod Statement
hi def link dirTime Comment
hi def link dirDirectory Directory
hi def link dirLink Type
hi def link dirStatusSelNum Constant
hi def link dirStatusSelPath Directory
hi def link dirStatusSortBy Constant
hi def link dirStatusHidden Constant
hi def link dirStatusFilter Constant
hi def link dirMark DiffChange

b:current_syntax = "dir"
