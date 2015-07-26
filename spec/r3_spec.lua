package.path = './waco-kid/?.lua;'..package.path
local r3 = require 'ffi.r3'

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

describe('r3', function()
  it('does the things', function()
    local r = r3()
    r.add({uri='/lol', method = r.methods.GET, fn = function() return '/lol' end})
    r.add({uri='/lol1', method = r.methods.ALL, fn = function() return '/lol1all' end})
    r.add({uri='/lol1', method = r.methods.GET, fn = function() return '/lol1' end})
    r.add({uri='/lol/{id}', method = r.methods.ALL, fn = function() return '/lol/id' end})
    r.finalize()
    assert.equal('/lol1', r.match('/lol1', r.methods.GET, 'localhost', {}))
    assert.equal('/lol/id', r.match('/lol/1', r.methods.GET, 'localhost', {}))
  end)
end)
