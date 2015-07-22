local router = require 'router'
local hosts = {}

local function setHost(host, routes)
  local r = router:new()
  for k, v in pairs(routes) do
    r:get(k, function() ngx.var.upstream = v.upstream() end)
  end
  hosts[host] = r
end

local function removeHost(host)
  hosts[host] = nil
end

local function compileRoutes(cache, frontends)
  local routes = {}
  for _, frontend in pairs(frontends) do
    local backend = cache.backends:get(frontend.BackendId)
    local upstream = function()
      return backend[math.random(#backend)]
    end
    local _, _, path = frontend.Route:find('Path%(["\']([^"\']*)["\']%)')
    path = path or ''
    path = path:gsub('<([^>]*)>', ':%1')
    routes[path] = {upstream = upstream}
  end
  return routes
end

local function initializeRoutes(cache)
  --manufacture initial routes
  local h = {}
  local list = cache.frontends:get('*') or {}
  for fid in pairs(list) do
    local f = cache.frontends:get(fid)
    local _, _, hostId = f.Route:find('Host%(["\']([^"\']*)["\']%)')
    hostId = hostId or '*'
    local host = h[hostId]
    if not host then
      host = {}
      h[hostId] = host
    end
    host[#host+1] = f
  end

  for host, frontends in pairs(h) do
    setHost(host, compileRoutes(cache, frontends))
  end
end

local function match(host, uri)
  local r = hosts[host] or hosts['*']
  if not r then return nil, 'unknown host '..host end
  local ok, err = r:execute('GET', uri)
  if not ok then return false end
  return true
end

return {
  match = match,
  setHost = setHost,
  removeHost = removeHost,
  compileRoutes = compileRoutes,
  initializeRoutes = initializeRoutes,
}
