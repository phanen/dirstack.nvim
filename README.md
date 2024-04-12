# dirstack.nvim

A smart directory history navigator similar `tagstack`

## features
* avoid duplicated history record
* auto ignore/sweep deleted directory in history
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

## todo
* [x] refactor as "hybride" mode (avoid duplicated entries + stack-like discard)
* [x] handle deleted directory history
* [ ] `[num][operate]`
* [ ] limit dir cache/list size
* [ ] colorful info
* [ ] fzf-lua integration
