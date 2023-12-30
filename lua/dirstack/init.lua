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

local switch_to = function(new_node)
  if new_node == nil then
    -- vim.api.nvim_err_writeln "no such node"
    return
  end
  -- NOTE: switch node first, then DirChanged
  node = new_node
  local dir = cd(node.dir)
  -- TODO: dir has been delete
  if dir then vim.notify(dir .. " -> " .. node.dir) end
end

local info = function()
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
