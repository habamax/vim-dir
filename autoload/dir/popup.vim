vim9script


# Show popup menu with actions.
# Actions is a list of dict [{name: string, Action: func}]
# for example:
# var actions = [
#     {name: "Create directory", Action: DoCreateDir},
#     {name: "Rename", Action: DoRename}
# ]
export def Menu(actions: list<dict<any>>)
    var menu_items = actions->mapnew((_, v) => v.name)
    popup_menu(menu_items, {
        pos: 'botleft',
        line: 'cursor-1',
        col: 'cursor',
        moved: 'WORD',
        callback: (id, result) => {
                if result > 0
                    actions[result - 1].Action()
                endif
            }
        })
enddef


export def YesNo(text: any, DialogCallback: func)
    var msg = []
    if type(text) == v:t_string
        msg->add(text)
    else
        msg += text
    endif
    var winid = popup_dialog(msg + ["", "yes  |  no"], {
        filter: 'popup_filter_yesno',
        pos: 'botleft',
        line: 'cursor-1',
        col: 'cursor',
        border: [],
        highlight: 'ErrorMsg',
        callback: (id, result) => {
            if result == 1
                var view = winsaveview()
                DialogCallback()
                winrestview(view)
            endif
        },
        padding: [0, 1, 0, 1]})
        win_execute(winid, $":call setline(line('$') - 1, repeat('─', {winwidth(winid)}))")
        win_execute(winid, $":%cen {winwidth(winid)}")

        hi def dirActionChar cterm=reverse,bold,underline gui=reverse,bold,underline
        win_execute(winid, $"syn match YesNo 'yes  \\|  no' transparent contains=Yes,No")
        win_execute(winid, $"syn match Yes '\\zsy\\zees' contained | hi def link Yes DirActionChar")
        win_execute(winid, $"syn match No '\\zsn\\zeo' contained | hi def link No DirActionChar")
enddef


# Returns winnr of created popup window
export def ShowAtCursor(text: any, title: string = ''): number
    var winnr = popup_atcursor(text, {
            title: empty(title) ? "" : $" {title} ",
            padding: [0, 1, 0, 1],
            border: [],
            pos: "botleft",
            maxheight: &lines - 5,
            maxwidth: &columns - 5,
            filter: "PopupFilter",
            filtermode: 'n',
            mapping: 0
          })
    return winnr
enddef


export def Show(text: any, title: string = ''): number
    var winnr = popup_create(text, {
            title: empty(title) ? "" : $" {title} ",
            padding: [0, 1, 0, 1],
            border: [],
            pos: "center",
            minwidth: &columns / 2,
            minheight: &lines / 3,
            maxheight: &lines - 5,
            maxwidth: &columns - 5,
            filter: "PopupFilter",
            filtermode: 'n',
            mapping: 0
          })
    return winnr
enddef


def PopupFilter(winid: number, key: string): bool
    if key == "\<Space>"
        win_execute(winid, "normal! \<C-d>\<C-d>")
        return true
    endif
    if key == "j"
        win_execute(winid, "normal! \<C-d>")
        return true
    endif
    if key == "g"
        win_execute(winid, "normal! gg")
        return true
    endif
    if key == "G"
        win_execute(winid, "normal! G")
        return true
    endif
    if key == "k"
        win_execute(winid, "normal! \<C-u>")
        return true
    endif
    if key == "\<ESC>" || key == "q" || key == "i"
        popup_close(winid)
        return true
    endif
    return true
enddef


# Synchronous confirmation dialog:
#   `text` is either a string or a list of strings
#   `answer` is a list of "buttons"
# Example:
#   var result = popup.Confirm("Override file?", [
#           {text: "&yes",  act: 'y'},
#           {text: "&no",   act: 'n'},
#           {text: "&all",  act: 'a'},
#           {text: "n&one", act: 'o'}
#       ])
#  if result == 0
#      echo "yes"
#  ...
# Returns -1 if Escape is pressed
# Returns  0 if Enter is pressed
export def Confirm(text: any, answer: list<dict<any>>): number
    if len(answer) < 2 | throw "Should be at least 2 answers!" | endif
    var msg = []
    if type(text) == v:t_string
        msg->add({text: text})
    else
        msg += text->mapnew((_, v) => {
                return {text: v}
            })
    endif
    msg += [{text: ""}]

    hi def dirActionChar cterm=reverse,bold,underline gui=reverse,bold,underline
    if empty(prop_type_get('DirActionChar'))
        prop_type_add('DirActionChar', {highlight: 'dirActionChar'})
    endif

    var answer_txt = answer->mapnew((_, v) => v.text)->join(' | ')
    var props = []
    var idx = answer_txt->stridx('&')
    while idx != -1
        props->add({col: idx + 1, length: 1, type: 'DirActionChar'})
        answer_txt = answer_txt->substitute('&', '', '')
        idx = answer_txt->stridx('&')
    endwhile
    var winid = popup_create(msg + [{text: answer_txt, props: props}], {
        pos: 'botleft',
        line: 'cursor-1',
        col: 'cursor',
        border: [],
        highlight: 'ErrorMsg',
        padding: [0, 1, 0, 1]})

    win_execute(winid, $":%cen {winwidth(winid)}")
    win_execute(winid, $":call setline(line('$') - 1, repeat('─', {winwidth(winid)}))")

    var chars = answer->mapnew((_, v) => v.act)
    redraw
    while 1
        var ch = nr2char(getchar(0))
        if ch == "\<ESC>"
            popup_close(winid)
            return -1
        endif
        if ch == "\<CR>"
            popup_close(winid)
            return 0
        endif
        var result = chars->index(ch)
        if result >= 0
            popup_close(winid)
            return result
        endif
        sleep 50m
    endwhile
    return -1
enddef
