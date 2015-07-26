package.path = './waco-kid/?.lua;'..package.path
local socket = require 'socket'

local etcd = require 'etcd'
local route = require 'route'

local function MockLRUCache()
  return {
    data = {},
    get = function(self, key)
      return self.data[key]
    end,
    set = function(self, key, value)
      self.data[key] = value
    end
  }
end

local function MockCache()
  return {
    frontends = MockLRUCache(),
    backends = MockLRUCache(),
  }
end

local r3 = require 'ffi.r3'
local r = r3()

r.add({uri='/lol', method = r.methods.GET, fn=function() return '/lol' end})
r.add({uri='/lol1', method = r.methods.ALL, fn=function() return '/lol1all' end})
r.add({uri='/lol1', method = r.methods.GET, fn=function() return '/lol1' end})
r.add({uri='/lol/{id}', method=r.methods.ALL, fn=function() return '/lol/id' end})
r.finalize()

local num = 100000000
local time = socket.gettime()
for i = 1, num do
  local upstream = r.match('/lol/1', r.methods.GET, 'localhost', {})
end
print((socket.gettime() - time)..'s for '..num)
