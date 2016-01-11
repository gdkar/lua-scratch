local fl = require 'fl'
local Q = setmetatable({},{ __call = function(q, size)
    local size = size or 0
    if size < 64 then size = 64 end
    local qlst = { }
    local data = { }
    local head = nil
    local tail = nil
    local qlen  = 0
    local flst = fl(size)
    local fput,fget = flst.put, flst.get
    local function put(item)
        local idx  = fget()
        data[idx]  = item
        if head == nil then head       = idx end
        if tail ~= nil then qlst[tail] = idx end
        tail       = idx
        qlen       = qlen + 1
    end
    local function get()
        if head == nil then return end
        local idx,item = head
        item,data[idx] = data[idx],nil
        head,qlst[idx] = qlst[idx],0
        fput(idx)
        qlen = qlen - 1
        return item
    end
    local function len() return qlen end
    for i = 1,size do qlst[i], data[i] = 0, 0 end
    return setmetatable({ data = data, put  = put, get  = get, len = len },{ __len = len })
end})

return Q
