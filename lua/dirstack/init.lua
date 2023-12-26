local head = {
  prev = nil,
  next = nil,
  dir = nil,
}

local node = head

local cd = function(path)
  local bak = vim.o.eventignore
  vim.o.eventignore = "DirChanged"
  local prev_dir = vim.fn.chdir(path)
  vim.o.eventignore = bak
  return prev_dir
end

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
      callback = function()
        local cwd = vim.fn.getcwd()
        -- if cwd == node.dir then return end
        node.next = { next = nil, prev = node, dir = cwd }
        node = node.next
        vim.print "fuck"
      end,
    })
  end,
}
