################################################################################
                                    VIM-DIR
################################################################################

File manager for Vim.

**WIP**

.. image:: https://user-images.githubusercontent.com/234774/178149719-1a77e114-728b-42e9-9530-701f1a701380.gif


Commands and Maps
=================

``:Dir [path]`` to open a path as a directory listing.

- :kbd:`Backspace` or :kbd:`u` -- one directory up.
- :kbd:`Enter` or :kbd:`o` -- open a file or a directory under cursor.
- :kbd:`O` -- open a file or a directory under cursor with OS.
- :kbd:`s` -- open a file or a directory under cursor in a split.
- :kbd:`v` -- open a file or a directory under cursor in a vertical split.
- :kbd:`t` -- open a file or a directory under cursor in a tab.
- :kbd:`i` -- preview a file (first 100 lines)


Features (To Do)
================

- ✓ (2022-07-10) Navigate file system, show contents like ``ls``.

- ✓ (2022-07-10) Open files/directories in splits/tabs.

- Cache to reuse dir contents.

- Sorting.

- Filtering.

- ✓ (2022-07-11) Open files with external applications (``xdg-open``, ``open``, ``start``).

- Bookmarks (hotlist).

- Basic file operations support:

  - ✓ (2022-07-10) Create a file (use ``:e filename`` from ``Dir`` buffer)
  - Create a directory
  - Delete a files/directories
  - Copy a files/directories
  - Move a files/directories
  - chmod? chown?

- Explore feasibility of mass rename ala ``qmv``/``vidir``

- Explore feasibility of networking (mc like shell or sftp links to machines).


Non Features
============

- ✗ No treeview, no sidepanel.
