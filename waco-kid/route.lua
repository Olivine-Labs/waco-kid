local r3 = require 'ffi.r3'

local router

local function addRoutes(routes)
  for k, v in pairs(routes) do
    router.add(k, function(c)
      if v.host and c.host ~= v.host then
        return
      end

      if v.method and c.method ~= v.method then
        return
      end

      if v.headers then
        for k, v in pairs(v.headers) do
          if c.headers[k] ~= v then
            return
          end
        end
      end

      return v.upstream()
    end)
  end
  router.finalize()
end

local function compileRoutes(cache, frontends)
  local routes = {}
  for fid, frontend in pairs(frontends) do
    local backend = cache.backends:get(frontend.BackendId)
    local upstream = function()
      return backend[math.random(#backend)]
    end
    local path, host, method
    local headers = {}
    frontend.Route:gsub('Path%(["\']([^"\']*)["\']%)', function(m) path = m end)
    frontend.Route:gsub('Host%(["\']([^"\']*)["\']%)', function(m) host = m end)
    frontend.Route:gsub('Method%(["\']([^"\']*)["\']%)', function(m) method = m end)
    frontend.Route:gsub('Header%(["\']([^"\']*)["\'],[%s]?["\']([^"\']*)["\']%)', function(header, value)
      headers[header] = value
    end)
    if path then
      path = path:gsub('<([^>]*)>', ':%1')
    else
      path = '/'
    end
    routes[path] = {
      upstream = upstream,
      host = host,
      method = method,
      headers = headers,
    }
  end
  return routes
end

local function initializeRoutes(cache)
  if router then router.free() end
  router = r3()
  --manufacture initial routes
  local list = cache.frontends:get('*') or {}
  local frontends = {}
  for fid in pairs(list) do
    frontends[fid] = cache.frontends:get(fid)
  end

  addRoutes(compileRoutes(cache, frontends))
end

local function match(c)
  local ok = router.match(c)
  if ok then return true, ok(c) end
  return false
end

return {
  match = match,
  addRoutes = addRoutes,
  compileRoutes = compileRoutes,
  initializeRoutes = initializeRoutes,
}
