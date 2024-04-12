if exists('g:loaded_dirstack') | finish | endif
let g:loaded_dirstack = 1

command! Dirs lua require('dirstack').hist()
command! Dirp lua require('dirstack').prev()
command! Dirn lua require('dirstack').next()
command! ClearDirs lua require('dirstack').clear()
