local helpers = require('nvim-test.helpers')
local clear = helpers.clear
local exec_lua = helpers.exec_lua
local eq = helpers.eq
local fn = helpers.fn

local call = setmetatable({}, {
  __index = function(_, k)
    return function()
      exec_lua(function(k0) return require('dirstack')[k0]() end, k)
    end
  end,
})

---@return string
local check_cwd = function()
  local dir = exec_lua(function() return require('dirstack').curr.key end)
  eq(fn.getcwd(), dir)
  return dir
end

---@alias test.view table
---@return test.view
local view = function()
  local v = exec_lua(function()
    return vim.iter(require('dirstack').lru:pairs(true)):map(function(key) return key end):totable()
  end)
  v.curr = check_cwd()
  return v
end

---@param v test.view
local check = function(v) eq(v, view()) end

local go_prev = function()
  call.prev()
  check_cwd()
end

local go_next = function()
  call.next()
  check_cwd()
end

---@param dir string
local chdir = function(dir)
  fn.chdir(dir)
  check_cwd()
end

describe('test', function()
  before_each(function()
    clear()
    exec_lua(function()
      ---@diagnostic disable-next-line: no-unknown
      package.loaded['dirstack'] = nil
      vim.opt.rtp:append('.')
      vim.cmd.runtime { 'plugin/dirstack.lua', bang = true }
      require('dirstack')
      local tmpdir = vim.fs.dirname(vim.fn.tempname())
      local tmpname = function(name) return vim.fs.joinpath(tmpdir, name) end
      -- sadly we cannot even use vim.fn outside with `-ll`...
      _G.D = {
        a = vim.fn.getcwd(),
        b = tmpname('b'),
        c = tmpname('c'),
        d = tmpname('d'),
        e = tmpname('e'),
        f = tmpname('f'),
        g = tmpname('g'),
        h = tmpname('h'),
      }
      for _, d in pairs(D) do
        assert(vim.fn.mkdir(d, 'p') == 1)
      end
    end)
    ---@type table<string, string>
    _G.D = exec_lua(function() return _G.D end)
  end)

  it('next/prev', function()
    -- check edge
    check { D.a, curr = D.a }
    go_next()
    check { D.a, curr = D.a }
    go_prev()
    check { D.a, curr = D.a }

    -- nothing happend
    chdir(D.a)
    check { D.a, curr = D.a }

    chdir(D.b)
    check { D.a, D.b, curr = D.b }
    chdir(D.b)
    check { D.a, D.b, curr = D.b }
    chdir(D.c)
    check { D.a, D.b, D.c, curr = D.c }
    chdir(D.d)
    check { D.a, D.b, D.c, D.d, curr = D.d }
    chdir(D.d)
    chdir(D.d)
    check { D.a, D.b, D.c, D.d, curr = D.d }

    -- check edge again
    go_prev()
    check { D.a, D.b, D.c, D.d, curr = D.c }
    go_next()
    check { D.a, D.b, D.c, D.d, curr = D.d }
    go_prev()
    check { D.a, D.b, D.c, D.d, curr = D.c }
    go_prev()
    check { D.a, D.b, D.c, D.d, curr = D.b }
    go_prev()
    check { D.a, D.b, D.c, D.d, curr = D.a }
    go_prev()
    go_prev()
    check { D.a, D.b, D.c, D.d, curr = D.a }

    go_next()
    check { D.a, D.b, D.c, D.d, curr = D.b }
    go_next()
    check { D.a, D.b, D.c, D.d, curr = D.c }
    go_next()
    go_next()
    check { D.a, D.b, D.c, D.d, curr = D.d }
    go_next()
    go_next()
    check { D.a, D.b, D.c, D.d, curr = D.d }

    -- at the edge(actually head, anyway...), cd to old dir
    chdir(D.e)
    check { D.a, D.b, D.c, D.d, D.e, curr = D.e }
    chdir(D.d)
    check { D.a, D.b, D.c, D.e, D.d, curr = D.d }
    chdir(D.e)
    check { D.a, D.b, D.c, D.d, D.e, curr = D.e }
    chdir(D.c)
    check { D.a, D.b, D.d, D.e, D.c, curr = D.c }
    chdir(D.b)
    check { D.a, D.d, D.e, D.c, D.b, curr = D.b }
    chdir(D.a)
    check { D.d, D.e, D.c, D.b, D.a, curr = D.a }

    -- at the edge, cd to new dir
    chdir(D.g)
    check { D.d, D.e, D.c, D.b, D.a, D.g, curr = D.g }

    go_prev()
    go_prev()
    go_prev()
    check { D.d, D.e, D.c, D.b, D.a, D.g, curr = D.c }
    -- at the middle, cd to old dir (right)
    chdir(D.a)
    check { D.g, D.b, D.d, D.e, D.c, D.a, curr = D.a }

    go_prev()
    go_prev()
    check { D.g, D.b, D.d, D.e, D.c, D.a, curr = D.e }
    -- at the middle, cd to pwd (always no-op)
    chdir(D.e)
    check { D.g, D.b, D.d, D.e, D.c, D.a, curr = D.e }
    -- at the middle, cd to old dir (left)
    chdir(D.d)
    check { D.a, D.c, D.g, D.b, D.e, D.d, curr = D.d }

    -- left edge, insert new node
    for _ = 1, 10 do
      go_prev()
    end
    -- left edge...
    check { D.a, D.c, D.g, D.b, D.e, D.d, curr = D.a }
    chdir(D.h)
    check { D.d, D.e, D.b, D.g, D.c, D.a, D.h, curr = D.h }
  end)

  -- tired... fuzzy is better than lean
  for _ = 1, os.getenv('CI') and 200 or 10 do
    it('random chdir' .. _, function()
      check_cwd()
      check { D.a, curr = D.a }
      eq(false, (pcall(chdir, 'non-exist')))
      check { D.a, curr = D.a }
      chdir(D.b)

      ---@type string[]
      local dirs = vim.tbl_values(D)
      math.randomseed(os.time())
      for _ = 1, 20 do
        for _, dir in ipairs(dirs) do
          if math.random() > 0.5 then chdir(dir) end
        end
      end
    end)

    it('random any-op' .. _, function()
      math.randomseed(os.time())
      local ops = {
        function() go_next() end,
        function() go_next() end,
        function() go_next() end,
        function() go_next() end,
        function() go_prev() end,
        function() go_prev() end,
        function() go_prev() end,
        function() go_prev() end,
        function() eq(false, (pcall(chdir, 'non-exist1'))) end,
        function() eq(false, (pcall(chdir, 'non-exist2'))) end,
        function() chdir(D.a) end,
        function() chdir(D.b) end,
        function() chdir(D.c) end,
        function() chdir(D.d) end,
        function() chdir(D.e) end,
        function() chdir(D.f) end,
        function() chdir(D.g) end,
        function() chdir(D.h) end,
      }
      for _ = 1, 100 do
        local op = ops[math.ceil(math.random() * #ops)]
        op()
      end
      -- go_next, go_prev, rep(10, string.gmatch('abcdefghi'))
    end)
  end
end)
