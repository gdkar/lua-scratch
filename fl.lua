local ffi,bit=require'ffi',require'bit'
local vec = require'ffivec'
local Freelist = setmetatable({},{__call = function(fl, _size)
    local head = 1
    local size = _size or 0
    if size < 1 then size = 1 end
    local data = vec(size)
    local function put(idx)
        data[idx],head = head, idx
    end
    local function get()
        if head > 0 then
            local idx
            local idx = head
            head = data[head]
            return idx
        else
            size       = size + 1
            data[size] = 0
            return size
        end
    end
    local function len() return size end
    for i = 1,size do data[size-i] = i-1 end
    local self = setmetatable({
        data = data,
        put  = put,
        get  = get,
        len  = len,
    },{__len = len})
    return self
end,})
function Freelist.put(fl,idx) fl.put(idx) end
function Freelist.get(fl) return fl.get() end
function Freelist.len(fl) return fl.len() end

return Freelist
