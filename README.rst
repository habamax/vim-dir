################################################################################
                       VIM-DIR: Browse directories in Vim
################################################################################

:Minimum requirements: ``Vim9``, ``Huge``

**WIP**, use at your own risk:

- there might be bugs;

- beware of dangerous file operations like move/rename/delete, only me testing
  it probably is not enough :).

Note that, copy/move file operations are way slower compared to "real" file
managers.

.. image:: https://user-images.githubusercontent.com/234774/178149719-1a77e114-728b-42e9-9530-701f1a701380.gif



Commands and Mappings
=====================

Global commands
---------------

- ``:Dir [path]`` — open a path as a directory listing.

- Use regular ``:edit``/``:e`` command to refresh directory listing.


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

- :kbd:`Backspace` or :kbd:`u` — one directory up.
- :kbd:`Enter` or :kbd:`o` — open a file or a directory under cursor.
- :kbd:`O` — open a file/directory with OS.
- :kbd:`s` — open a file/directory in a split.
- :kbd:`S` — open a file/directory in a vertical split.
- :kbd:`t` — open a file/directory in a tab.
- :kbd:`]]` — jump over directories forward, place cursor on a first file/last
  directory.
- :kbd:`[[` — jump over directories backward, place cursor on the last/first
  directory.


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


Bookmarks
~~~~~~~~~

- :kbd:`~` or :kbd:`g~` — open home directory.
- :kbd:`g1` up to  :kbd:`g0` — open numbered bookmark.
- :kbd:`Ctrl-A` :kbd:`1` up to  :kbd:`Ctrl-A` :kbd:`0` — set numbered
  bookmark for a current directory.


Sort
~~~~

- :kbd:`g` :kbd:`,` — sort current buffer dir by size.
- :kbd:`g` :kbd:`.` — sort current buffer dir by time.
- :kbd:`g` :kbd:`/` — sort current buffer dir by name.


Filter
~~~~~~

- :kbd:`.` — toggle ``.hidden`` files/directories


Settings
========

- ``g:dir_open_ext`` — if a file/directory is matched against regexes in a
  list, open it using OS.
- ``g:dir_invert_split`` — by default :kbd:`s` splits horizontally and :kbd:`S`
  splits vertically. Set to ``1``/``true`` to make the opposite.
- ``g:dir_sort_by`` — sort by one of ``name``, ``size`` or ``time``. Default is
  ``name``.
- ``g:dir_sort_desc`` — if true, sort ``desc``, otherwise ``asc``. Default is
  ``false``.
- ``g:dir_show_hidden`` — show/hide ``.hidden`` files/directories. Default is
  ``true``.


Maybe Features
==============

- Support archives: view contents/create/add/extract (using ``7z`` maybe?).

- Background file operations (copy/move/delete).

- Mass rename ala ``qmv``/``vidir`` (explore feasibility).

- Networking ala ``netrw`` or ``mc`` with shell/sftp links to machines (explore
  feasibility). Here probably I should rely on openssh.



Non Features
============

- ✗ No treeview, no sidepanel.
