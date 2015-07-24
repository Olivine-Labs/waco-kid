local log = {}

function log.error(str)
  if ngx then
    ngx.log(ngx.ERR, str)
  else
    print('error:', str)
  end
end

function log.warn(str)
  if ngx then
    ngx.log(ngx.WARN, str)
  else
    print('warning:', str)
  end
end

function log.info(str)
  if ngx then
    ngx.log(ngx.INFO, str)
  else
    print('info:', str)
  end
end

function log.debug(str)
  if ngx then
    ngx.log(ngx.DEBUG, str)
  else
    print('debug:', str)
  end
end

return log
