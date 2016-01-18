local fl, vec = require 'fl.flist', require 'fl.vec'
local Set = setmetatable({}, { __call = function(set)
    local flst  = fl()
    local fget, fput = flst.get, flst.put
    local data = setmetatable({ },{ __mode = 'kv'})
    local size = 0
    local fill = 0
    local function sadd(item)
        local idx = fget()
        if idx > size then size = idx end
        data[idx] = item
        fill = fill + 1
    end
    local function sdel(item)
        for i = 1,size do
            if data[i] == item then
                fput(i)
                data[i] = nil
                fill = fill - 1
                return
            end
        end
    end
    local function sfill() return fill end
    local function snext( set, idx )
        idx = idx + 1
        if idx > size then return end
        local v = data[idx]
        if not v then return snext( set, idx )
        else return idx, v end
    end
    local function siter()
        local idx = 0
        return function()
            local v
            idx,v = snext(nil,idx)
            return v
        end
    end
    local self = setmetatable({ add = sadd, del = sdel, fill = sfill, iter = siter }, { })
    return self
end})

return Set
