local api = vim.api
require('dirstack')
api.nvim_create_autocmd('Dirchanged', {
  group = api.nvim_create_augroup('dirstack', { clear = true }),
  callback = function(ev) require('dirstack').on(ev.file) end,
})
