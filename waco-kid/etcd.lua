local json = require 'cjson'
local log = require 'log'

local ETCD_URL = os.getenv('WK_ETCD_URL') or 'http://172.17.0.4:2379'
local ETCD_PREFIX = os.getenv('WK_ETCD_PREFIX') or 'vulcand'

local function updateCache(cache, data)
  local key = {}
  if data.dir then
    for _, node in pairs(data.nodes) do
      updateCache(cache, node)
    end
  else
    for part in string.gmatch(data.key, '([^/]+)') do
      key[#key+1] = part
    end

    if #key == 4 and key[2] == 'frontends' and key[4] == 'frontend' then
      local fid = key[3]
      local ok, err = pcall(function()
        local newValue = json.decode(data.value)
        local frontends = cache.frontends:get('*') or {}
        frontends[fid] = true
        cache.frontends:set('*', frontends)
        cache.frontends:set(fid, newValue)
      end)
      if not ok then log.error('Bad frontend '..fid..':'..err) end
    elseif #key == 5 and key[2] == 'backends' and key[4] == 'servers' then
      local bid = key[3]
      local ok, err = pcall(function()
        local server = json.decode(data.value)
        if server.URL then
          local backend = cache.backends:get(bid) or {}
          backend[key[5]] = server.URL
          cache.backends:set(bid, backend)
        end
      end)
      if not ok then log.error('Bad backend '..bid..':'..err) end
    end
  end
end

local function getUpdates(cache, route, all)
  local http = require 'resty.http'
  local httpc = http.new()
  local waitIndex = nil
  local uri = table.concat({
    ETCD_URL,
    "/v2/keys/",
    ETCD_PREFIX,
    "/?recursive=true",
    (not all and '&wait=true' or ''),
    (waitIndex and '&waitIndex='..waitIndex or ''),
  })
  local res, err = httpc:request_uri(uri, {
    method = "GET",
  })
  if res then
    if res.status == 200 then
      local data = json.decode(res.body)
      local m, c = data.node.modifiedIndex, data.node.createdIndex
      waitIndex = math.max(m, c)
      updateCache(cache, data.node)
      route.initializeRoutes(cache)
    end
  else
    log.error(err)
  end
end

return {
  updateCache = updateCache,
  getUpdates = getUpdates,
}
