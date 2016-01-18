local require = require
local ffi,bit,vec=require'ffi',require'bit',(require 'cvec').new_int
local sizeof,cdef, typeof,new,cast,C = ffi.sizeof,ffi.cdef, ffi.typeof,ffi.new,ffi.cast,ffi.C

local Freelist = setmetatable({},{__call = function(fl, _size)
    local head      = -1
    local size      = _size or 0
    if size < 16 then size = 16 end
    local data      = vec(size)
    data:resize(size)
    local function put(idx)
        data[idx] = head
        head      = idx
    end
    local function get()
        if head > 0 then
            local idx = head
            head = data.ptr[head-1]
            return idx
        else
            size       = size + 1
            data[size] = 0
            return size
        end
    end
    local function len() return size end
    for i = 1,size-1 do data[i] = i+1 end
    local self = setmetatable({
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
