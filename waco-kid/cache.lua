local lrucache = require 'resty.lrucache'

local FRONTEND_MAX = os.getenv('WK_FRONTEND_MAX') or 100000
local BACKEND_MAX = os.getenv('WK_BACKEND_MAX') or 100000
local MATCH_MAX = os.getenv('WK_MATCH_MAX') or 100000

local backends = lrucache.new(BACKEND_MAX)
local frontends = lrucache.new(FRONTEND_MAX)
local match = lrucache.new(MATCH_MAX)

return {
  frontends = frontends,
  backends = backends,
  match = match,
}
