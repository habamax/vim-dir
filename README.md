# VIM-DIR: file manager

![vim-dir](https://user-images.githubusercontent.com/234774/178149719-1a77e114-728b-42e9-9530-701f1a701380.gif)

More screencasts:

- [Navigation][1]
- [Bookmarks and History][2]
- [Copy/move/delete/rename][3]
- [Filtering][4]
- [Compare with netrw][5]

[1]: https://user-images.githubusercontent.com/234774/181280095-de13afb2-2db0-439f-a388-bb9e853fc989.gif
[2]: https://user-images.githubusercontent.com/234774/181280105-a95771e8-f5d9-4cb1-b871-b24663a9ba89.gif
[3]: https://user-images.githubusercontent.com/234774/181280108-c98aec2a-6a02-4f40-b1ff-62d7afc5301c.gif
[4]: https://user-images.githubusercontent.com/234774/181280112-361093ee-6c22-4c25-9a49-529f8222da10.gif
[5]: https://user-images.githubusercontent.com/234774/181282440-259d6043-f065-4bc7-945a-48aaf269f5f0.gif


## Commands and Mappings

### Global commands

- `:Dir [path]` — open a path as a directory listing.

- Use `:Dir` or regular `:edit`/`:e` command to refresh directory listing.


### Local commands

- `:DirFilter[!] {regex}` — Show files/directories matching `regex`.
  With `!` hide files/directories matching `regex`:

      # Show files/dirs with   e   in the name
      :DirFilter e
      # Hide files/dirs with   e   in the name
      :DirFilter! e

      # Hide files/dirs with   e.*p   in the name
      :DirFilter! e.*p

- `:DirFilterClear` — clear filter.

- `:DirBookmark` — save bookmark for a current directory.
  Bookmarks are saved in `~/.config/vim-dir/bookmarks.json` or
  `$APPDATA/vim-dir/bookmarks.json` depending on OS.

- `:DirBookmarkJump` — jump to bookmarked directory.

- `:DirHistoryJump` — jump to directory from history.


## Global mappings

There are no global mappings.

You can set at least one yourself to quickly call `Dir`:

    nnoremap <bs> <cmd>Dir<cr>

With that mapping you would be able to trigger a `Dir` with `Backspace`
showing current buffer file name in a directory list. Consequent
`Backspace` presses would open parent directories.


Other global mappings might be, for example:

    nnoremap <space>gd <cmd>Dir ~/Documents<cr>
    nnoremap <space>gD <cmd>Dir ~/Downloads<cr>


### Local mappings

#### Navigation

- `Backspace` or `u` or `-` — one directory up.
- `Enter` or `o` — open a file or a directory under cursor.
- `O` — open a file/directory with OS.
- `s` — open a file/directory in a split.
- `S` — open a file/directory in a vertical split.
- `t` — open a file/directory in a tab.
- `Ctrl-R` — refresh directory.
- `]]` — jump over directories forward, place cursor on a first file/last
  directory.
- `[[` — jump over directories backward, place cursor on the last/first
  directory.
- `gj` — open quick jump menu.


#### File operations

- `i` — preview a file (first 100 lines) or show dir info (nothing on
  windows).
- `x` — toggle selection of file/directory.
- `X` — toggle selection of all files/directories (select/unselect all).
- `D` or `dd` — delete files/directories.
- `R` or `rr` — rename files/directories.
- `p` — copy selected files/directories into current directory.
- `P` — move selected files/directories into current directory.
- `A` — open actions menu.
- `C` — create directory.
- `cc` — create file.


#### Bookmarks & History

- `~` or `g~` — open home directory.
- `g1` up to  `g0` — open numbered bookmark.
- `Ctrl-A` `1` up to  `Ctrl-A` `0` — set numbered
  bookmark for a current directory.
- `gb` — open bookmarks jump menu.
- `gh` — open history jump menu. History is saved for each directory where
  file was opened for editing.


#### Sort

- `g,` — sort current buffer dir by size.
- `g.` — sort current buffer dir by time.
- `g/` — sort current buffer dir by name.


#### Filter and View

- `.` — toggle `.hidden` files/directories.
- `>` — widen the dir view (adding some columns).
- `<` — shrink the dir view (removing some columns).


## Settings

- `g:dir_open_os` — if a file/directory is matched against file extension in a
  list, open it using OS.
- `g:dir_invert_split` — by default `s` splits horizontally and `S`
  splits vertically. Set to `1`/`true` to make the opposite.
- `g:dir_sort_by` — sort by one of `name`, `size` or `time`. Default is
  `name`.
- `g:dir_sort_desc` — if true, sort `desc`, otherwise `asc`. Default is
  `false`.
- `g:dir_show_hidden` — show/hide `.hidden` files/directories. Default is
  `true`.
- `g:dir_history_size` — maximum numbers of directories in history. Default is
  `100`.
- `g:dir_columns` — columns for the dir view. Default is

  - Windows: `perm,size,time,name`
  - Linux/Other: `perm,user,group,size,time,name`

  Columns `perm` and `name` are mandatory and should be in order.

- `g:dir_change_cwd` — change current working directory on file opening.
  Default is `0`.


## Maybe Features

- Support archives: view contents/create/add/extract (using `7z` maybe?).

- Background file operations (copy/move/delete).



Non Features
============

- ✗ No treeview, no sidepanel.

- ✗ Networking ala `netrw` or `mc`.
