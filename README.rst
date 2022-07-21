################################################################################
                       VIM-DIR: Browse directories in Vim
################################################################################

:Minimum requirements: ``Vim9``

**WIP**

.. image:: https://user-images.githubusercontent.com/234774/178149719-1a77e114-728b-42e9-9530-701f1a701380.gif



Commands and Mappings
=====================

Global commands
---------------

``:Dir [path]`` to open a path as a directory listing.


Global mappings
---------------

There are no global mappings.

You can set at least one yourself to quickly call ``Dir``:

.. code::

  nnoremap <bs> <cmd>Dir<cr>

With that mapping you would be able to trigger a ``Dir`` with :kbd:`Backspace`
showing current buffer file name in a directory list. Consequent
:kbd:`Backspace` presses would open parent directories.


Local mappings
--------------

- :kbd:`Backspace` or :kbd:`u` -- one directory up.
- :kbd:`Enter` or :kbd:`o` -- open a file or a directory under cursor.
- :kbd:`O` -- open a file/directory with OS.
- :kbd:`s` -- open a file/directory in a split.
- :kbd:`S` -- open a file/directory in a vertical split.
- :kbd:`t` -- open a file/directory in a tab.
- :kbd:`i` -- preview a file (first 100 lines) or show dir tree (if `tree` is
  available)
- :kbd:`D` or :kbd:`dd` -- delete files/directories
- :kbd:`R` or :kbd:`rr` -- rename files/directories
- :kbd:`A` -- open actions menu


Settings
========

- ``g:dir_open_ext`` -- if a file/directory is matched against regexes in a
  list, open it using OS.
- ``g:dir_invert_split`` -- by default :kbd:`s` splits horizontally and :kbd:`S`
  splits vertically. Set to ``1``/``true`` to make the opposite.


Features (To Do)
================

- ✓ (2022-07-10) Navigate file system, show contents like ``ls``.

- ✓ (2022-07-10) Open files/directories in splits/tabs.

- ✓ (2022-07-19) Cache to reuse dir contents.

- Sorting.

- Filtering.

- ✓ (2022-07-11) Open files with external applications (``xdg-open``, ``open``, ``start``).

- Bookmarks (hotlist).

- Basic file operations support:

  - ✓ (2022-07-10) Create a file (use ``:e filename`` from ``Dir`` buffer)
  - ✓ (2022-07-14) Rename file/directory
  - ✓ (2022-07-15) Create a directory
  - ✓ (2022-07-13) Delete files/directories (be careful here)
  - ✓ (2022-07-21) Copy files/directories (be careful here)
  - Move files/directories
  - chmod? chown?
  - report errors if happened during file ops.


Maybe Features
==============

- View archive contents (using ``7z`` maybe?)

- Mass rename ala ``qmv``/``vidir`` (explore feasibility).

- Networking ala netrw or mc with shell/sftp links to machines (explore
  feasibility).



Non Features
============

- ✗ No treeview, no sidepanel.
