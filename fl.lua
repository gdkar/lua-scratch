local ffi,bit=require'ffi',require'bit'
local Freelist = setmetatable({},{__call = function(fl, _size)
    local head = 0
    local data = { }
    local size = _size or 0
    local function put(idx)
        data[idx] = head
        head      = idx
    end
    local function get()
        if head > 0 then
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
    for i = 1,size do put(i) end
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
