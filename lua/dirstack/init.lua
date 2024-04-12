local M = {}

-- a hybrid mode of default jumplist and tagstack
local cache = {}

local head = {}
local tail = { p = head }
head.n = tail
local curr = ...

local skip_hook = false

local init = function()
  local dir = vim.fn.getcwd()
  local node = { n = tail, p = head, dir = dir }
  head.n = node
  tail.p = node
  cache = { [dir] = node }
  curr = node
end

M.setup = function()
  init()
  vim.api.nvim_create_autocmd('DirChanged', {
    group = vim.api.nvim_create_augroup('dirstack', { clear = true }),
    callback = function(ev)
      local dir = ev.file

      -- explictly check instead of hack
      if skip_hook or dir == curr.dir or dir == '' then return end

      -- default jumplist-like: skip duplicate
      local node = cache[dir]
      if node then -- duplicate
        node.p.n = node.n
        node.n.p = node.p
        node.n = tail
        node.p = tail.p
        tail.p.n = node
        tail.p = node
        curr = node
        return
      end

      -- tagstack-like: insert node after current one (instead of in the tail)
      -- then we discard unneeded history
      node = { n = tail, p = curr, dir = dir }
      tail.p = node
      local to_delete = curr.n
      while to_delete and to_delete ~= tail do
        cache[to_delete.dir] = nil
        to_delete = to_delete.n
      end
      curr.n = node
      curr = node
      cache[dir] = node
    end,
  })
end

local count = nil
M.prev = function(level)
  level = level or 0

  local node = curr.p
  if not node or node == head then
    -- inject a favorite meme
    return vim.notify(('Human is Dead; Mismatch [%s]'):format(level), vim.log.levels.WARN)
  end

  local dir = node.dir
  -- tail call it, stack safe (:
  if not vim.uv.fs_stat(dir) then
    cache[dir] = nil
    curr.p = node.p
    return M.prev(level + 1)
  end

  if not dir then return vim.notify('No dir field', vim.log.levels.WARN) end

  curr = node

  -- always need trigger DirChanged* autocmd (e.g. for nvim-tree sync feat)
  -- set flag here as workaround
  skip_hook = true
  vim.fn.chdir(dir)
  skip_hook = false

  count = count and count or vim.v.count1
  if count == 1 then
    count = nil
    return
  end
  count = count - 1
  return M.prev()
end

M.next = function(level)
  level = level or 0

  local node = curr.n
  if not node or node == tail then
    return vim.notify(('Human is Dead; Mismatch [%s]'):format(level), vim.log.levels.WARN)
  end

  local dir = node.dir
  if not vim.uv.fs_stat(dir) then
    cache[dir] = nil
    curr.n = node.n
    return M.next(level + 1)
  end

  if not dir then return vim.notify('No dir field', vim.log.levels.WARN) end

  curr = node

  skip_hook = true
  vim.fn.chdir(dir)
  skip_hook = false

  count = count and count or vim.v.count1
  if count == 1 then
    count = nil
    return
  end
  count = count - 1
  return M.next()
end

M.hist = function()
  local node = head.n
  local msg = ''
  while node and node ~= tail and node.dir do
    if node == curr then
      msg = msg .. '> ' .. node.dir .. '\n'
    else
      msg = msg .. '  ' .. node.dir .. '\n'
    end
    node = node.n
  end
  vim.print(msg)
end

M.clear = init

M.history = M.hist

return M
