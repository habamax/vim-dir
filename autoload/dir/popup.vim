vim9script

var popup_borderchars     = get(g:, "popup_borderchars", ['─', '│', '─', '│', '┌', '┐', '┘', '└'])
var popup_borderchars_t   = get(g:, "popup_borderchars_t", ['─', '│', '─', '│', '├', '┤', '┘', '└'])
var popup_borderhighlight = get(g:, "popup_borderhighlight", ['Normal'])
var popup_highlight       = get(g:, "popup_highlight", 'Normal')
var popup_cursor          = get(g:, "popup_cursor", '▏')
var popup_number          = get(g:, "popup_number", false)

export def YesNo(text: any, DialogCallback: func)
    var msg = []
    if type(text) == v:t_string
        msg->add(text)
    else
        msg += text
    endif
    var winid = popup_dialog(msg + ["", "yes  |  no"], {
        filter: 'popup_filter_yesno',
        pos: 'center',
        border: [],
        borderchars: popup_borderchars,
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

export def Show(text: any, title: string = '', Setup: func(number) = null_function): number
    var height = min([&lines - 6, text->len()])
    var minwidth = (&columns * 0.6)->float2nr()
    var pos_top = ((&lines - height) / 2) - 1
    var winid = popup_create(text, {
        title: empty(title) ? "" : $" {title} ",
        line: pos_top,
        minwidth: minwidth,
        maxwidth: (&columns - 5),
        minheight: height,
        maxheight: height,
        border: [],
        borderchars: popup_borderchars,
        borderhighlight: popup_borderhighlight,
        highlight: popup_highlight,
        drag: 0,
        wrap: 1,
        cursorline: false,
        padding: [0, 1, 0, 1],
        mapping: 0,
        filter: (winid: number, key: string) => {
            var new_minwidth = popup_getpos(winid).core_width
            if new_minwidth > minwidth
                minwidth = new_minwidth
                popup_move(winid, {minwidth: minwidth})
            endif
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
        }
    })
    if Setup != null_function
        Setup(winid)
    endif
    return winid
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
        pos: 'center',
        border: [],
        borderchars: popup_borderchars,
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
export def Select(title: string, items: list<any>, Callback: func(any, string), Setup: func(number) = null_function, close_on_bs: bool = false)
    if empty(prop_type_get('PopupSelectMatch'))
        hi def link PopupSelectMatch Constant
        prop_type_add('PopupSelectMatch', {highlight: "PopupSelectMatch", override: true, priority: 1000, combine: true})
    endif
    var prompt = ""
    var items_dict: list<dict<any>>
    var items_count = items->len()
    if items_count > 0 && items[0]->type() != v:t_dict
        items_dict = items->mapnew((_, v) => {
            return {text: v}
        })
    else
        items_dict = items
    endif

    var filtered_items: list<any> = [items_dict]
    var maxwidth = (&columns * 0.9)->float2nr()
    var minwidth = max([min([70, maxwidth]), (&columns * 0.6)->float2nr()])
    var maxheight = &lines - 9
    var minheight = min([maxheight, max([items->len(), 10])])
    var pos_top = ((&lines - minheight) / 2) - 1
    var scrollbar_before_update = 0

    def Format(itemsAny: list<any>, props: list<any>): list<any>
        if itemsAny[0]->len() == 0 | return [] | endif

        var max_visible_pretext_len = 0
        var max_visible_posttext_len = 0
        var max_visible_text_len = 0
        var i = 0
        while i < maxheight && i < itemsAny[0]->len()
            if max_visible_text_len < len(itemsAny[0][i].text)
                max_visible_text_len = len(itemsAny[0][i].text)
            endif
            var pretext = get(itemsAny[0][i], "pretext", "")
            if max_visible_pretext_len < len(pretext)
                max_visible_pretext_len = len(pretext)
            endif
            var posttext = get(itemsAny[0][i], "posttext", "")
            if max_visible_posttext_len < len(posttext)
                max_visible_posttext_len = len(posttext)
            endif
            i += 1
        endwhile
        if max_visible_text_len + max_visible_pretext_len + max_visible_posttext_len >= maxwidth
            max_visible_text_len = maxwidth - max_visible_pretext_len - max_visible_posttext_len
        endif

        if itemsAny->len() > 1
            return itemsAny[0]->mapnew((idx, v) => {
                var pretext = get(v, "pretext", "")
                var posttext = get(v, "posttext", "")
                var text = pretext
                if len(pretext) < max_visible_pretext_len
                    text ..= repeat(" ", max_visible_pretext_len - len(pretext))
                endif
                text ..= v.text
                if !empty(posttext)
                    if len(v.text) < max_visible_text_len
                        text ..= repeat(" ", max_visible_text_len - len(v.text))
                    endif
                    text ..= posttext
                endif
                return {text: text, props: itemsAny[1][idx]->mapnew((_, c) => {
                    return {col: len(pretext) + v.text->byteidx(c) + 1, length: 1, type: 'PopupSelectMatch'}
                })}
            })
        else
            return itemsAny[0]->mapnew((_, v) => {
                var pretext = get(v, "pretext", "")
                var posttext = get(v, "posttext", "")
                var text = pretext
                if len(pretext) < max_visible_pretext_len
                    text ..= repeat(" ", max_visible_pretext_len - len(pretext))
                endif
                text ..= v.text
                if !empty(posttext)
                    if len(v.text) < max_visible_text_len
                        text ..= repeat(" ", max_visible_text_len - len(v.text))
                    endif
                    text ..= posttext
                endif

                return {text: text}
            })
        endif
    enddef

    def AlignPopups(pwinid: number, winid: number)
        var width = popup_getpos(winid).core_width + (scrollbar_before_update - popup_getpos(winid).scrollbar)
        popup_move(winid, {
            minwidth: width,
            maxwidth: width
        })

        width = popup_getpos(winid).core_width + popup_getpos(winid).scrollbar
        var padding = (popup_number ? 0 : 1)
        popup_move(pwinid, {
            minwidth: width + padding,
            maxwidth: width + padding
        })
    enddef

    def UpdatePopups(pwinid: number, winid: number)
        var count_f = printf("%1$*2$.*3$d",
            items_count > 0 ? filtered_items[0]->len() : 0,
            0,
            items_count->string()->len())
        var count = $"{count_f}/{items_count}"
        if filtered_items[0]->empty()
            win_execute(winid, $"if &l:cul | setl {popup_number ? "nonu" : ""} nocul | endif")
        else
            win_execute(winid, $"if !&l:cul | setl {popup_number ? "nu" : ""} cul | endif")
        endif
        popup_setoptions(pwinid, {title: $" {title} ({count}) "})
        popup_settext(pwinid, $"> {prompt}{popup_cursor}")
        scrollbar_before_update = popup_getpos(winid).scrollbar
        popup_settext(winid, Format(filtered_items, []))
    enddef

    # hide cursor
    set t_ve=
    var gui_cursor = hlget("Cursor")
    hlset([{name: 'Cursor', cleared: true}])

    def RestoreCursor()
        set t_ve&
        if hlget("Cursor")[0]->get('cleared', false)
            hlset(gui_cursor)
        endif
    enddef

    var ignore_input = ["\<cursorhold>", "\<ignore>", "\<Nul>",
          \ "\<LeftMouse>", "\<LeftRelease>", "\<LeftDrag>", $"\<2-LeftMouse>",
          \ "\<RightMouse>", "\<RightRelease>", "\<RightDrag>", "\<2-RightMouse>",
          \ "\<MiddleMouse>", "\<MiddleRelease>", "\<MiddleDrag>", "\<2-MiddleMouse>",
          \ "\<MiddleMouse>", "\<MiddleRelease>", "\<MiddleDrag>", "\<2-MiddleMouse>",
          \ "\<X1Mouse>", "\<X1Release>", "\<X1Drag>", "\<X2Mouse>", "\<X2Release>", "\<X2Drag>",
          \ "\<ScrollWheelLeft", "\<ScrollWheelRight>"
    ]
    # this sequence of bytes are generated when left/right mouse is pressed and
    # mouse wheel is rolled
    var ignore_input_wtf = [128, 253, 100]

    var popts = {
        minwidth: minwidth,
        maxwidth: maxwidth,
        borderhighlight: popup_borderhighlight,
        highlight: popup_highlight,
        drag: 0,
        wrap: 1,
        scrollbar: true,
        cursorline: false,
        padding: [0, 0, 0, 0],
        mapping: 0,
    }
    var pwinid = popup_create([$"> {popup_cursor}"],
        popts->copy()->extend({
            border: [1, 1, 0, 1],
            borderchars: popup_borderchars,
            line: pos_top,
            maxheight: 1,
            minheight: 1,
        })
    )
    var winid = popup_create(Format(filtered_items, []), popts->copy()->extend({
        border: [1, 1, 1, 1],
        borderchars: popup_borderchars_t,
        line: pos_top + 2,
        padding: [0, 0, 0, (popup_number ? 0 : 1)],
        minheight: minheight,
        maxheight: maxheight,
        filter: (id, key) => {
            if key == "\<esc>"
                popup_close(id, -1)
                popup_close(pwinid)
                RestoreCursor()
            elseif ["\<cr>", "\<C-j>", "\<C-v>", "\<C-t>", "\<C-o>"]->index(key) > -1
                    && !filtered_items[0]->empty() && items_count > 0
                popup_close(id, {idx: getcurpos(id)[1], key: key})
                popup_close(pwinid)
                RestoreCursor()
            elseif ["\<Right>", "\<PageDown>"]->index(key) > -1
                win_execute(id, 'normal! ' .. maxheight .. "\<C-d>")
            elseif ["\<Left>", "\<PageUp>"]->index(key) > -1
                win_execute(id, 'normal! ' .. maxheight .. "\<C-u>")
            elseif key == "\<Home>"
                win_execute(id, "normal! gg")
            elseif key == "\<End>"
                win_execute(id, "normal! G")
            elseif ["\<tab>", "\<C-n>", "\<Down>", "\<ScrollWheelDown>"]->index(key) > -1
                var ln = getcurpos(id)[1]
                win_execute(id, "normal! j")
                if ln == getcurpos(id)[1]
                    win_execute(id, "normal! gg")
                endif
            elseif ["\<S-Tab>", "\<C-p>", "\<Up>", "\<ScrollWheelUp>"]->index(key) > -1
                var ln = getcurpos(id)[1]
                win_execute(id, "normal! k")
                if ln == getcurpos(id)[1]
                    win_execute(id, "normal! G")
                endif
            # Ignoring fancy events and double clicks, which are 6 char long: `<80><fc> <80><fd>.`
            elseif ignore_input->index(key) == -1 && strcharlen(key) != 6 && str2list(key) != ignore_input_wtf
                if key == "\<C-u>"
                    prompt = ""
                    filtered_items = [items_dict]
                elseif key == "\<C-w>"
                    prompt = matchstr(prompt, '\v^.{-}\ze(([[:punct:][:space:]]+)|([[:lower:][:upper:][:digit:]]+\s*))$')
                    if empty(prompt)
                        filtered_items = [items_dict]
                    else
                        filtered_items = items_dict->matchfuzzypos(prompt, {key: "text"})
                    endif
                elseif (key == "\<C-h>" || key == "\<BS>")
                    if empty(prompt) && close_on_bs
                        popup_close(id, {idx: getcurpos(id)[1], key: key})
                        popup_close(pwinid)
                        RestoreCursor()
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
                UpdatePopups(pwinid, id)
                AlignPopups(pwinid, id)
            endif
            return true
        },
        callback: (id, result) => {
            popup_close(pwinid)
            RestoreCursor()
            if result->type() == v:t_number
                if result > 0
                    Callback(filtered_items[0][result - 1], "")
                endif
            else
                Callback(filtered_items[0][result.idx - 1], result.key)
            endif
        }
    }))

    win_execute(winid, "setl cursorlineopt=both")
    UpdatePopups(pwinid, winid)
    AlignPopups(pwinid, winid)

    if Setup != null_function
        Setup(winid)
    endif
enddef
