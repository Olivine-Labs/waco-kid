local ffi = require 'ffi'
local bit = require 'bit'

local methods = {
  ALL = ffi.new('int', 254),
  GET = ffi.new('int', 2),
  POST = ffi.new('int', bit.lshift(2, 1)),
  PUT = ffi.new('int', bit.lshift(2, 2)),
  DELETE = ffi.new('int', bit.lshift(2, 3)),
  PATCH = ffi.new('int', bit.lshift(2, 4)),
  HEAD = ffi.new('int', bit.lshift(2, 5)),
  OPTIONS = ffi.new('int', bit.lshift(2, 6)),
}

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
  local nodes = {}
  local cdata = {}

  local function add(c)
    local err = ffi.new("char**")
    local route = r3.r3_route_createl(c.uri, #c.uri)
    cdata[#cdata+1] = route
    route.request_method = c.method or methods.ALL
    if c.host then
      route.host_len = #c.host
      local host = ffi.new('char[?]', #c.host, c.host)
      route.host = host
      cdata[#cdata+1] = host
    end

    route.data = ffi.cast('void *', ffi.new('int', #routes+1))

    local node = nodes[c.uri]
    if not node then
      node = r3.r3_tree_insert_pathl_ex(r, c.uri, #c.uri, route, route.data, err);
      nodes[c.uri] = node
    else
      r3.r3_node_append_route(node, route)
    end
    if node == NULL then
      return nil, 'failed to add route '..c.method..':'..c.uri..' for host '..c.host
    end

    routes[#routes+1] = c.fn
    return true
  end

  local function finalize()
    local err = ffi.new("char*[1]")
    local ret = r3.r3_tree_compile(r, err)
    if ret ~= 0 then
      error(ffi.string(err))
    end
  end

  local hostCache = {}
  local m = ffi.gc(r3.match_entry_createl('', 0), freeMatch)
  local function match(uri, method, host, headers)
    local m = m
    m.path = uri
    m.path_len = #uri
    m.request_method = method
    local h = hostCache[host]
    if not h then
      local name = ffi.new('char[?]', #host, host)
      h = {name=name, len=ffi.new('int', #host)}
      hostCache[host] = h
    end
    m.host = h.name
    m.host_len = h.len

    local n = r3.r3_tree_match_route(r, m)
    if n ~= nil then
      local routeId = tonumber(ffi.cast('int', n.data))
      return routes[routeId](uri, method, host, headers)
    end

    return false
  end

  return {
    match = match,
    finalize = finalize,
    add = add,
    methods = methods,
  }
end
