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


# TODO: rename popup.Dialog to popup.YesNo
export def Dialog(text: any, DialogCallback: func)
    var msg = []
    if type(text) == v:t_string
        msg->add(text)
    else
        msg += text
    endif
    var winid = popup_dialog(msg + ["", "(y)es    (n)o"], {
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
