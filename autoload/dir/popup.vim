vim9script


# Show popup list, execute callback with a single parameter.
export def List(items: list<string>, title: string, MenuCallback: func(any))
    popup_create(items, {
        title: $' {title} ',
        pos: 'center',
        drag: 1,
        wrap: 0,
        border: [],
        cursorline: 1,
        padding: [0, 1, 0, 1],
        mapping: 0,
        filter: (id, key) => {
            if key == "\<esc>"
                popup_close(id, -1)
            elseif key == "\<cr>"
                popup_close(id, getcurpos(id)[1])
            elseif key == "\<tab>" || key == "\<C-n>"
                win_execute(id, "normal! j")
            elseif key == "\<S-tab>" || key == "\<C-p>"
                win_execute(id, "normal! k")
            else
                win_execute(id, $"search('[/\\-_]{key->escape('&*.\\')}')")
            endif
            return true
        },
        callback: (id, result) => {
                if result > 0
                    MenuCallback(items[result - 1])
                endif
            }
        })
enddef


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


# Popup menu with fuzzy filtering
export def FilterMenu(title: string, items: list<any>, Callback: func(any, string), Setup: func(number) = null_function, close_on_bs: bool = false)
    if empty(prop_type_get('FilterMenuMatch'))
        hi def link FilterMenuMatch Constant
        prop_type_add('FilterMenuMatch', {highlight: "FilterMenuMatch", override: true, priority: 1000, combine: true})
    endif
    var prompt = ""
    var hint = ">>> type to filter <<<"
    var items_dict: list<dict<any>>
    var items_count = items->len()
    if items_count < 1
        items_dict = [{text: ""}]
    elseif items[0]->type() != v:t_dict
        items_dict = items->mapnew((_, v) => {
            return {text: v}
        })
    else
        items_dict = items
    endif

    var filtered_items: list<any> = [items_dict]
    def Printify(itemsAny: list<any>, props: list<any>): list<any>
        if itemsAny[0]->len() == 0 | return [] | endif
        if itemsAny->len() > 1
            return itemsAny[0]->mapnew((idx, v) => {
                return {text: v.text, props: itemsAny[1][idx]->mapnew((_, c) => {
                    return {col: v.text->byteidx(c) + 1, length: 1, type: 'FilterMenuMatch'}
                })}
            })
        else
            return itemsAny[0]->mapnew((_, v) => {
                return {text: v.text}
            })
        endif
    enddef
    var height = min([&lines - 6, items->len()])
    var pos_top = ((&lines - height) / 2) - 1
    var winid = popup_create(Printify(filtered_items, []), {
        title: $" ({items_count}/{items_count}) {title}: {hint} ",
        line: pos_top,
        minwidth: (&columns * 0.6)->float2nr(),
        maxwidth: (&columns - 5),
        minheight: height,
        maxheight: height,
        border: [],
        borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        drag: 0,
        wrap: 1,
        cursorline: false,
        padding: [0, 1, 0, 1],
        mapping: 0,
        filter: (id, key) => {
            if key == "\<esc>"
                popup_close(id, -1)
            elseif ["\<cr>", "\<C-j>", "\<C-v>", "\<C-t>"]->index(key) > -1
                    && filtered_items[0]->len() > 0
                popup_close(id, {idx: getcurpos(id)[1], key: key})
            elseif key == "\<tab>" || key == "\<C-n>"
                var ln = getcurpos(id)[1]
                win_execute(id, "normal! j")
                if ln == getcurpos(id)[1]
                    win_execute(id, "normal! gg")
                endif
            elseif key == "\<S-tab>" || key == "\<C-p>"
                var ln = getcurpos(id)[1]
                win_execute(id, "normal! k")
                if ln == getcurpos(id)[1]
                    win_execute(id, "normal! G")
                endif
            elseif ["\<cursorhold>", "\<ignore>"]->index(key) == -1
                if key == "\<C-U>" && !empty(prompt)
                    prompt = ""
                    filtered_items = [items_dict]
                elseif (key == "\<C-h>" || key == "\<bs>")
                    if empty(prompt) && close_on_bs
                        popup_close(id, {idx: getcurpos(id)[1], key: key})
                        return true
                    endif
                    prompt = prompt->strcharpart(0, prompt->strchars() - 1)
                    if empty(prompt)
                        filtered_items = [items_dict]
                    else
                        filtered_items = items_dict->matchfuzzypos(prompt, {key: "text"})
                    endif
                elseif key =~ '\p'
                    prompt ..= key
                    filtered_items = items_dict->matchfuzzypos(prompt, {key: "text"})
                endif
                popup_settext(id, Printify(filtered_items, []))
                popup_setoptions(id, {title: $" ({filtered_items[0]->len()}/{items_count}) {title}: {prompt ?? hint} "})
            endif
            return true
        },
        callback: (id, result) => {
                if result->type() == v:t_number
                    if result > 0
                        Callback(filtered_items[0][result - 1], "")
                    endif
                else
                    Callback(filtered_items[0][result.idx - 1], result.key)
                endif
            }
        })

    win_execute(winid, "setl nu cursorline cursorlineopt=both")
    if Setup != null_function
        Setup(winid)
    endif
enddef
