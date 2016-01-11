#! /usr/bin/env luajit

local ffi = require'ffi'
local to, new = ffi.typeof,ffi.new
local function Freelist(size)
    local head = -1
    local data
    if size < 2^31 - 1 then
        data = new("int32_t[?]", size)
    elseif size < 2^52 - 1 then
        data = new("int64_t[?]", size)
    else
        return nil, "Size too large."
    end
    local function put(idx)
        data[idx] = head
        head      = idx
    end
    local function get()
        local idx = head
        if head >= 0 then
            head = data[idx]
            return idx
        else return nil, "No items available" end
    end
    for i = 0,size-1 do put(i) end
    local self = {
        size = size,
        data = data,
        put  = put,
        get  = get,
    }
    return self
end

local clock = os.clock
local count = select(1,...) or 1024*1024
local fl = Freelist(count + 1)
local items = { }
for j = 1,4 do
    local start = clock()
    for i=1,count do items[i] = fl.get() end
    local middle = clock()
    for i=1,count do fl.put(items[i]) end
    local finish = clock()

    io.write(string.format("getting %d items took %f seconds ( %E ns / item)\n", count, middle-start,(middle-start)*1e9 / count))
    io.write(string.format("putting %d items took %f seconds ( %E ns / item)\n", count, finish-middle,(finish-middle)*1e9 / count))
end
