local route = require 'route'

local ok, err = route.match(ngx.var.http_host, ngx.var.uri)

if not ok then
  ngx.log(ngx.WARN, err)
  ngx.exit(ngx.HTTP_NOT_FOUND)
end
