#! /usr/bin/env luajit

local ffi = require'ffi'
local to, new = ffi.typeof,ffi.new
local function Freelist(size)
    local head = 0
    local data = { }
    local size = size
    local function put(idx)
        data[idx] = head
        head      = idx
    end
    local function get()
        local idx = head
        if head > 0 and head <= size then
            head = data[idx]
            return idx
        else
            size       = size + 1
            data[size] = size + 1
            head       = 0
            return size
        end
    end
    local function len()
        return size
    end
    for i = 1,size do put(i) end
    local self = setmetatable({
        data = data,
        put  = put,
        get  = get,
        len  = len,
    },{__len = len})
    return self
end

local clock = os.clock
local count = select(1,...) or 2^16
local fl = Freelist(2^16)
local items = { }
local start = clock()
for i=1,count do items[i] = fl.get() end
local middle = clock()
for i=1,count do fl.put(items[i]) end
local finish = clock()

io.write(string.format("getting %d items took %f seconds ( %E ns / item)\n", count, middle-start,(middle-start)*1e9 / count))
io.write(string.format("putting %d items took %f seconds ( %E ns / item)\n", count, finish-middle,(finish-middle)*1e9 / count))
do
    local m = 0
    for i=1,#fl do m = math.max(fl.data[i],m) end
    print(#fl)
    io.write(string.format("maximum free list reference is %d\n",m))         
end
