local route = require 'route'

local upstream = route.match(
  ngx.var.uri,
  route.router.methods[ngx.req.get_method():upper()],
  ngx.var.http_host,
  ngx.req.get_headers()
)

if not upstream then
  ngx.log(ngx.WARN, upstream)
  ngx.exit(ngx.HTTP_NOT_FOUND)
  return
end

ngx.var.upstream = upstream
