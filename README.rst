********************************************************************************
                             VIM-DIR: file manager
********************************************************************************

:Minimum requirements: ``Vim9``, ``Huge version``

.. image:: https://user-images.githubusercontent.com/234774/178149719-1a77e114-728b-42e9-9530-701f1a701380.gif

More screencasts:

- Navigation_
- `Bookmarks and History`_
- `Copy/move/delete/rename`_
- Filtering_
- `Compare with netrw`_

.. _Navigation: https://user-images.githubusercontent.com/234774/181280095-de13afb2-2db0-439f-a388-bb9e853fc989.gif
.. _`Bookmarks and History`: https://user-images.githubusercontent.com/234774/181280105-a95771e8-f5d9-4cb1-b871-b24663a9ba89.gif
.. _`Copy/move/delete/rename`: https://user-images.githubusercontent.com/234774/181280108-c98aec2a-6a02-4f40-b1ff-62d7afc5301c.gif
.. _Filtering: https://user-images.githubusercontent.com/234774/181280112-361093ee-6c22-4c25-9a49-529f8222da10.gif
.. _`Compare with netrw`: https://user-images.githubusercontent.com/234774/181282440-259d6043-f065-4bc7-945a-48aaf269f5f0.gif


Commands and Mappings
=====================

Global commands
---------------

- ``:Dir [path]`` — open a path as a directory listing.

- Use ``:Dir`` or regular ``:edit``/``:e`` command to refresh directory listing.


Local commands
--------------

- ``:DirFilter[!] {regex}`` — Show files/directories matching ``{regex}``.
  With ``!`` hide files/directories matching ``{regex}``::

    # Show files/dirs with   e   in the name
    :DirFilter e
    # Hide files/dirs with   e   in the name
    :DirFilter! e

    # Hide files/dirs with   e.*p   in the name
    :DirFilter! e.*p

- ``:DirFilterClear`` — clear filter.

- ``:DirBookmark`` — save bookmark for a current directory.
  Bookmarks are saved in ``~/.config/vim-dir/bookmarks.json`` or
  ``$APPDATA/vim-dir/bookmarks.json`` depending on OS.

- ``:DirBookmarkJump`` — jump to bookmarked directory.

- ``:DirHistoryJump`` — jump to directory from history.


Global mappings
---------------

There are no global mappings.

You can set at least one yourself to quickly call ``Dir``:

.. code::

  nnoremap <bs> <cmd>Dir<cr>

With that mapping you would be able to trigger a ``Dir`` with :kbd:`Backspace`
showing current buffer file name in a directory list. Consequent
:kbd:`Backspace` presses would open parent directories.


Other global mappings might be, for example:

.. code::

  nnoremap <space>gd <cmd>Dir ~/Documents<cr>
  nnoremap <space>gD <cmd>Dir ~/Downloads<cr>


Local mappings
--------------

Navigation
~~~~~~~~~~

- :kbd:`Backspace` or :kbd:`u` or :kbd:`-` — one directory up.
- :kbd:`Enter` or :kbd:`o` — open a file or a directory under cursor.
- :kbd:`O` — open a file/directory with OS.
- :kbd:`s` — open a file/directory in a split.
- :kbd:`S` — open a file/directory in a vertical split.
- :kbd:`t` — open a file/directory in a tab.
- :kbd:`Ctrl-R` — refresh directory.
- :kbd:`]]` — jump over directories forward, place cursor on a first file/last
  directory.
- :kbd:`[[` — jump over directories backward, place cursor on the last/first
  directory.
- :kbd:`gj` — open quick jump menu.


File operations
~~~~~~~~~~~~~~~

- :kbd:`i` — preview a file (first 100 lines) or show dir info (nothing on
  windows).
- :kbd:`x` — toggle selection of file/directory.
- :kbd:`X` — toggle selection of all files/directories (select/unselect all).
- :kbd:`D` or :kbd:`dd` — delete files/directories.
- :kbd:`R` or :kbd:`rr` — rename files/directories.
- :kbd:`p` — copy selected files/directories into current directory.
- :kbd:`P` — move selected files/directories into current directory.
- :kbd:`A` — open actions menu.
- :kbd:`C` — create directory.
- :kbd:`cc` — create file.


Bookmarks & History
~~~~~~~~~~~~~~~~~~~

- :kbd:`~` or :kbd:`g~` — open home directory.
- :kbd:`g1` up to  :kbd:`g0` — open numbered bookmark.
- :kbd:`Ctrl-A` :kbd:`1` up to  :kbd:`Ctrl-A` :kbd:`0` — set numbered
  bookmark for a current directory.
- :kbd:`gb` — open bookmarks jump menu.
- :kbd:`gh` — open history jump menu. History is saved for each directory where
  file was opened for editing.


Sort
~~~~

- :kbd:`g` :kbd:`,` — sort current buffer dir by size.
- :kbd:`g` :kbd:`.` — sort current buffer dir by time.
- :kbd:`g` :kbd:`/` — sort current buffer dir by name.


Filter and View
~~~~~~~~~~~~~~~

- :kbd:`.` — toggle ``.hidden`` files/directories.
- :kbd:`>` — widen the dir view (adding some columns).
- :kbd:`<` — shrink the dir view (removing some columns).


Settings
========

- ``g:dir_open_os`` — if a file/directory is matched against file extension in a
  list, open it using OS.
- ``g:dir_invert_split`` — by default :kbd:`s` splits horizontally and :kbd:`S`
  splits vertically. Set to ``1``/``true`` to make the opposite.
- ``g:dir_sort_by`` — sort by one of ``name``, ``size`` or ``time``. Default is
  ``name``.
- ``g:dir_sort_desc`` — if true, sort ``desc``, otherwise ``asc``. Default is
  ``false``.
- ``g:dir_show_hidden`` — show/hide ``.hidden`` files/directories. Default is
  ``true``.
- ``g:dir_history_size`` — maximum numbers of directories in history. Default is
  `100`.
- ``g:dir_columns`` — columns for the dir view. Default is

  - Windows: ``perm,size,time,name``
  - Linux/Other: ``perm,user,group,size,time,name``

  Columns ``perm`` and ``name`` are mandatory and should be in order.

- ``g:dir_change_cwd`` — change current working directory on file opening.
  Default is ``0``.


Maybe Features
==============

- Support archives: view contents/create/add/extract (using ``7z`` maybe?).

- Background file operations (copy/move/delete).



Non Features
============

- ✗ No treeview, no sidepanel.

- ✗ Mass rename ala ``qmv``/``vidir`` (explore feasibility).

- ✗ Networking ala ``netrw`` or ``mc``.

