local route = require 'route'

local upstream = route.match({
  host=ngx.var.http_host,
  uri=ngx.var.uri,
  method=ngx.req.get_method(),
  headers=ngx.req.get_headers(),
})

if not upstream then
  ngx.log(ngx.WARN, upstream)
  ngx.exit(ngx.HTTP_NOT_FOUND)
  return
end

ngx.var.upstream = upstream
