# dirstack.nvim

A directory navigator, with similar model to vim's builtin undolist.

## install

use `lazy.nvim`
```lua
{
  'phanen/dirstack.nvim',
  keys = {
    { '<leader><c-p>', "<cmd>lua require('dirstack').prev()<cr>" },
    { '<leader><c-n>', "<cmd>lua require('dirstack').next()<cr>" },
    { '<leader><c-x>', "<cmd>lua require('dirstack').info()<cr>" },
  },
},
```

## todo
* [ ] remove duplicated entries
* [ ] jumplists like info/command
* [ ] number `[num][operation]`
