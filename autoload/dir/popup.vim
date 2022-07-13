vim9script


export def Dialog(text: string, DialogCallback: func)
    var winid = popup_dialog([text, "", "", "(y)es    (n)o"], {
        filter: 'popup_filter_yesno',
        pos: 'botleft',
        line: 'cursor-1',
        col: 'cursor',
        border: [],
        highlight: 'ErrorMsg',
        borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        callback: (id, result) => {
            if result == 1
                var view = winsaveview()
                DialogCallback()
                winrestview(view)
            endif
        },
        padding: [0, 1, 0, 1]})
        win_execute(winid, $":$cen {winwidth(winid)}")
enddef


# Returns winnr of created popup window
export def ShowAtCursor(text: any, title: string = ''): number
    var winnr = popup_atcursor(text, {
            title: empty(title) ? "" : $" {title} ",
            padding: [0, 1, 0, 1],
            border: [],
            borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
            pos: "botleft",
            maxheight: &lines - 5,
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
            borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
            pos: "center",
            minwidth: &columns / 2,
            minheight: &lines / 3,
            maxheight: &lines - 5,
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
