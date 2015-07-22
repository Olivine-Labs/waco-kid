local cache = require 'cache'
local etcd = require 'etcd'
local route = require 'route'

ngx.timer.at(0, function()
  etcd.getUpdates(cache, route, true)
  ngx.timer.at(0, function()
    while true do
      local ok, err = pcall(function()
        etcd.getUpdates(cache, route)
      end)
      if not ok then ngx.log(ngx.ERR, err) end
    end
  end)
end)
