local backend = os.getenv('WK_BACKEND') or 'etcd'

return {
  data = require(backend),
}
