# dirstack.nvim

A smart directory history navigator similar to `tagstack`.

## features
* similar to `tagstack`
  * new records will be added after current one
  * subsequent records will be discard
* differ from `tagstack`
  * records will be never duplicated
  * duplicated ones will be move after current one
* auto ignore and sweep deleted directory in history
* commands
  * `Dirs`: list your dirs history, in `:jumps` format
  * `Dirp`: goto previous dir in directory history
  * `Dirn`: goto next dir in directory history
  * `CleanDirs`: clean you dir

## install
use `lazy.nvim`
```lua
{
  'phanen/dirstack.nvim',
  event = 'DirchangedPre',
  keys = {
    { '<leader><c-p>', "<cmd>lua require('dirstack').prev()<cr>" },
    { '<leader><c-n>', "<cmd>lua require('dirstack').next()<cr>" },
    { '<leader><c-l>', "<cmd>lua require('dirstack').hist()<cr>" },
  },
  opts = {},
},
```

## example

`:Dirs`
```
  /a
  /b
> /c
```

`:Dirp`
```
  /a
> /b
  /c
```

`:cd /c | cd /d | cd /e | cd /f | cd /f` (ignore duplicated)
```
  /a
  /c
  /d
  /e
> /f
```

`:Dirp`, `:Dirp`
```
  /a
  /c
> /d
  /e
  /f
```

`:cd /a`
```
  /c
  /d
> /a
```

## todo
* [x] refactor as "stack" mode
* [x] handle deleted directory history
* [x] `[number][operation]`
* [ ] `vim.ui.select`
* [ ] what if dir died due to moved?
* [ ] colorful info
* [ ] limit dir cache/list size
