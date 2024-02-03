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

local list_cb = function(cb, ...)
  local it = head
  while it do
    cb(it, ...)
    it = it.next
  end
end

-- TODO: better to use non-nest event
local switch_to = function(new_node)
  if new_node == nil then return end
  -- NOTE: switch node first, then DirChanged
  node = new_node
  local dir = cd(node.dir)
  -- TODO: dir has been delete
  if dir then vim.notify("-> " .. node.dir) end
end

local info = function()
  local msg = ""
  list_cb(function(it)
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
        if cwd == node.dir then return end
        push(cwd)
      end,
    })
  end,
}
