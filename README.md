# dirstack.nvim

A directory navigator, with similar model to vim's builtin undolist.

## install

use `lazy.nvim`
```lua
{
  "phanen/dirstack.nvim",
  event = "DirChangedPre",
  keys = {
    { "<c-p>", function() require("dirstack").prev() end },
    { "<c-n>", function() require("dirstack").next() end },
    { "<c-g>", function() require("dirstack").info() end },
  },
  config = true,
},
```
