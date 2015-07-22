local lrucache = require 'resty.lrucache'

local FRONTEND_MAX = os.getenv('WK_FRONTEND_MAX') or 100000
local BACKEND_MAX = os.getenv('WK_BACKEND_MAX') or 100000

local backends = lrucache.new(BACKEND_MAX)
local frontends = lrucache.new(FRONTEND_MAX)

return {
  frontends = frontends,
  backends = backends,
}
