---@diagnostic disable: duplicate-doc-field, duplicate-set-field, duplicate-doc-alias, unused-local
local api, fn, uv = vim.api, vim.fn, vim.uv

local u = {
  class = {
    lru = require('dirstack.lru').new,
  },
}

---START INJECT dirstack.lua

local M = {}

local log = function(msg) return vim.notify(('[Dirstack] %s'):format(msg)) end
M.lru = u.class.lru { ---@diagnostic disable-next-line: missing-fields
  { key = fn.getcwd() },
}
M.curr = M.lru.head.next

---@param dir string
M.chdir = function(dir)
  M._noau = true
  fn.chdir(dir)
  log(dir)
  M._noau = false
end

---@param dir string
M.on = function(dir)
  if M._noau or dir == '' or dir == M.curr.key then return end
  M.lru:access(dir)

  local head = M.lru.head
  local first = head.next
  local curr = M.curr
  local curr_prev = curr.prev
  M.curr = first

  if curr_prev == first then -- list is (head -> first -> curr)
    return
  end

  local second = first.next
  curr.prev = first
  first.next = curr

  local last = head.prev
  local tmp = curr_prev.prev ---@type lru.Node
  curr_prev.prev = last
  last.next = curr_prev

  while curr_prev ~= second do
    curr_prev.next = tmp
    local t = tmp.prev ---@type lru.Node
    tmp.prev = curr_prev
    curr_prev, tmp = tmp, t
  end

  head.prev = second
  second.next = head
end

---@param direction 'next'|'prev'
---@return nil
local nav_impl = function(direction)
  ---@param retry integer?
  ---@return nil
  local function goto_next_clean(retry)
    local node = M.curr[direction] ---@type lru.Node
    if node == M.lru.head then --
      return log(('%s (no %s)'):format(M.curr.key, direction))
    end
    local dir = node.key
    if not uv.fs_stat(dir) then
      retry = retry and retry + 1 or 1
      log(('%s deleted, retry(%s)'):format(dir, retry))
      M.curr[direction] --[[@type lru.Node]] = node[direction]
      M.lru:delete(node)
      return goto_next_clean(retry)
    end
    M.curr = node
    return M.chdir(dir)
  end
  return goto_next_clean()
end

---@param retry integer?
M.prev = function(retry) nav_impl('next') end

---@param retry integer?
M.next = function(retry) nav_impl('prev') end

return M
