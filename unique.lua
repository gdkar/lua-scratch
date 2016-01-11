#! /usr/bin/env luajit

local ffi = require'ffi'
local bit = require'bit'
local shr = bit.rshift
local function table_has(t,x)
    local low,hi = 1,#t
    if t[low] == x or t[hi] == x then return true end
    while hi > low do local mid = shr(hi+lo,1) end
    while hi > low + 1 do
        local mid = shr(hi+lo,1)
        
    end
    for _,e in ipairs(t) do
        if e==x then return true end
    end
    return false
end
local function table_unique(t)
    local res = { }
    for i,v in ipairs(t) do
        if not table_has(res,v) then res[#res+1]=v end
    end
    return res
end
local function table_unique1(self)
    local tmp = { }
    local idx = 1
    for i,v in ipairs(self) do
        if not tmp[v] then tmp[v], idx = idx, idx + 1 end
    end
    local res = { }
    for k,v in pairs(tmp) do res[v] = k end
    return res
end

local clock = os.clock
local count = select(1,...) or 1024
local reps  = select(2,...) or 64
local items = { }
local old_style = 0
local new_style = 0
for j = 1,reps do
    local tab = { }
    for i = 1,count do
        tab[i] = tostring(math.random(2^31-1))
    end
    local start = clock()
    local u0 = table_unique(tab)
    local middle = clock()
    local u1 = table_unique1(tab)
    local finish = clock()
    
    if #u0 ~= #u1 then io.write(string.format("Error, old length = %d, new length = %d\n", #u0, #u1)) end
    for i = 1,#u0 do
        if u0[i] ~= u1[i] then
            io.write(string.format("Error, disparity, u0[%d] = %d, u1[%d] = %d\n",
            i, u0[i], i, u1[i]))
        end
    end
    old_style = old_style + middle-start
    new_style = new_style + finish-middle
end
io.write(string.format("old style %d items took %f seconds ( %E ns / item)\n", count, old_style/reps ,old_style*1e9 / (reps*count)))
io.write(string.format("new style %d items took %f seconds ( %E ns / item)\n", count, new_style/reps ,new_style*1e9 / (reps*count)))

