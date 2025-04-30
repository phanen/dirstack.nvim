# dirstack.nvim

"dirstack" but spiral.

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
[test/dir_spec.lua](test/dir_spec.lua)
