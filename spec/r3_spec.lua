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
    r.add('/lol', function() print 'lol' end)
    r.add('/lol1', function() print 'lol1' end)
    r.finalize()
    assert(r.match({uri='/lol1'}))
  end)
end)
