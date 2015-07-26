local r3 = require 'ffi.r3'
local log = require 'log'

local function routeMatcher(uri, method, host, headers, v)
  if v.headers then
    for k, v in pairs(v.headers) do
      if c.headers[k] ~= v then
        return
      end
    end
  end

  if v.headersRegExp then
    for k, v in pairs(v.headersRegExp, 'aoj') do
      if ngx.re.match(c.headers[k], v) then
        return
      end
    end
  end
  return v.upstream()
end

local o = {}

function o.addRoutes(router, routes)
  for _, v in pairs(routes) do
    local ok, err = router.add({
      uri = v.uri,
      host = v.host,
      headers = v.headers,
      headersRegExp = v.headersRegExp,
      method = v.method and router.methods[v.method:upper()],
      fn = function(uri, method, host, headers) return routeMatcher(uri, method, host, headers, v) end,
    })
    if not ok then log.error(err) end
  end
end

function o.compileRoutes(cache, frontends)
  local routes = {}
  for fid, frontend in pairs(frontends) do
    local backend = cache.backends:get(frontend.BackendId)
    local serverIndex = math.random(#backend)
    local upstream = function()
      if serverIndex + 1 > #backend then
        serverIndex = 1
      else
        serverIndex = serverIndex + 1
      end
      return backend[serverIndex]
    end
    local path, host, method
    local headers, headersRegExp = {}, {}
    local luaRoute = frontend.Route:gsub('&&', ';')
    local function Path(p)
      path = p:gsub('<([^>]*)>', '{%1}')
    end
    local function Host(h)
      host = h
    end
    local function Header(name, value)
      headers[name] = value
    end
    local function HeaderRegExp(name, value)
      headersRegExp[name] = value
    end

    local routeContext = {
      Path = Path,
      PathRegExp = Path,
      Host = Host,
      HostRegExp = Host,
      Header = Header,
      HeaderRegExp = HeaderRegExp,
    }
    local Route = loadstring(luaRoute)
    setfenv(Route, routeContext)
    Route()
    if not path then
      path = '/'
    end
    routes[#routes+1] = {
      uri = path,
      upstream = upstream,
      host = host,
      method = method,
      headers = headers,
    }
  end
  table.sort(routes, function(a, b) return #a.uri>#b.uri end)
  return routes
end

function o.match()
  return false
end

function o.initializeRoutes(cache)
  local newRouter = r3()
  --manufacture initial routes
  local list = cache.frontends:get('*') or {}
  local frontends = {}
  for fid in pairs(list) do
    frontends[fid] = cache.frontends:get(fid)
  end

  o.addRoutes(newRouter, o.compileRoutes(cache, frontends))
  newRouter.finalize()
  local oldRouter = router
  o.router = newRouter
  o.match = o.router.match
  if oldRouter then oldRouter.free() end
end

return o
