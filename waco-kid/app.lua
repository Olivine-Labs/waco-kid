local cache = require 'cache'
local route = require 'route'
local config = require 'config'

ngx.timer.at(0, function()
  config.data.getUpdates(cache, route, true)
  ngx.timer.at(0, function()
    while true do
      local ok, err = pcall(function()
        config.data.getUpdates(cache, route)
      end)
      if not ok then ngx.log(ngx.ERR, err) end
    end
  end)
end)
