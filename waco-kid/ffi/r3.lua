local ffi = require 'ffi'

local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local function readAll(file)
  local f = io.open(file, "rb")
  local content = f:read("*all")
  f:close()
  return content
end

ffi.cdef(readAll(script_path()..'r3.h'))
local r3 = ffi.load('r3')

local freeMatch = function(o) r3.match_entry_free(o) end
local freeTree = function(o) r3.r3_tree_free(o) end

return function()
  local r = ffi.gc(r3.r3_tree_create(10), freeTree)
  local routes = {}

  local function add(uri, fn)
    routes[uri] = fn
    local err = ffi.new("char*[1]")
    r3.r3_tree_insert_routel_ex(r, 0, uri, #uri, nil, err)
  end

  local function finalize()
    local err = ffi.new("char*[1]")
    local ret = r3.r3_tree_compile(r, err)
    if ret ~= 0 then
      error(ffi.string(err))
    end
  end

  local function match(c)
    local match = ffi.gc(r3.match_entry_createl(c.uri, #c.uri), freeMatch)
    local m = r3.r3_tree_match_route(r, match);
    if m ~= nil then
      return routes[ffi.string(m.path)]
    end
    return false
  end

  return {
    match = match,
    finalize = finalize,
    add = add,
  }
end
