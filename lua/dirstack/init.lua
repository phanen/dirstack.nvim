local head = {
  prev = nil,
  next = nil,
  dir = nil,
}
local node = head
local cd = vim.fn.chdir

local push = function(path)
  node.next = { next = nil, prev = node, dir = path }
  node = node.next
end

local list_callback = function(callback, ...)
  local it = head
  while it do
    callback(it, ...)
    it = it.next
  end
end

local switch_to = function(new_node)
  if new_node == nil then
    if dbg then vim.api.nvim_err_writeln "no such node" end
    return
  end
  -- NOTE: switch node first, then DirChanged
  node = new_node
  local dir = cd(node.dir)
  -- TODO: dir has been delete
  if dir then vim.notify(dir .. " -> " .. node.dir) end
end

local info = function()
  local msg = ""
  list_callback(function(it)
    local pad = (it == node and "> " or "  ")
    msg = msg .. pad .. it.dir .. "\n"
  end)
  vim.notify(msg)
end

return {
  info = info,
  next = function() switch_to(node.next) end,
  prev = function() switch_to(node.prev) end,
  setup = function()
    node.dir = vim.fn.getcwd()
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function(ev)
        local cwd = ev.file
        -- `prev`/`next` should not trigger `DirChanged`, but set `eventignore` may break other plugins
        -- to determine if we're from `prev`/`next` previously, this hack is sufficient to provide soundness
        if cwd == node.dir then return end
        push(cwd)
      end,
    })
  end,
}
