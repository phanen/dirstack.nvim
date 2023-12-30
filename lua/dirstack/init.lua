local head = {
  prev = nil,
  next = nil,
  dir = nil,
}

local node = head

local cd = vim.fn.chdir

return {
  info = function()
    local it = head
    local info = ""
    while it do
      if it == node then
        info = info .. "> " .. it.dir .. "\n"
      else
        info = info .. "  " .. it.dir .. "\n"
      end
      it = it.next
    end
    vim.notify(info)
  end,
  -- TODO: dir may be removed
  next = function()
    if node.next then
      node = node.next
      local dir = cd(node.dir)
      vim.notify(dir .. " -> " .. node.dir)
    else
      vim.api.nvim_err_writeln "dirlist: no next"
    end
  end,
  prev = function()
    if node.prev then
      node = node.prev
      local dir = cd(node.dir)
      vim.notify(dir .. " -> " .. node.dir)
    else
      vim.api.nvim_err_writeln "dirlist: no prev"
    end
  end,
  setup = function()
    node.dir = vim.fn.getcwd()
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function(ev)
        local cwd = vim.fn.getcwd()
        -- `prev`/`next` should not trigger `DirChanged`, but set `eventignore` may break other plugins
        -- to determine if we're from `prev`/`next` previously, this hack is sufficient to provide soundness
        if cwd == node.dir then return end
        node.next = { next = nil, prev = node, dir = cwd }
        node = node.next
      end,
    })
  end,
}
