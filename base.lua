#! /usr/bin/env luajit
local require = require
local ffi,bit = require'ffi',require'bit'
local to, new = ffi.typeof,ffi.new
local sprintf = string.format
local printf  = function(...) io.write(sprintf(...)) end
local clock = os.clock

local count = tonumber(select(1,...) or 2^16)
local reps  = tonumber(select(2,...) or 16)
local tests = {select(3,...)}

math.randomseed(os.clock())
local irand = new("int[?]",math.min(count,(2^18)-1))
local srand = { }
do
    for i = 1,math.min(count,(2^18)-1)do irand[i] = math.random(2^24-1) end
--    for i = 1,#irand do srand[i] = sprintf("%#x",irand[i]) end
end
do
    for i,name in ipairs(tests) do
--        local _G = setmetatable({},{ __index = _G})
        local test = require(name)
        local lpre = { }
        local lloop = { }
        local liter = { }
        local lpost = { }
        local pre, loop, post = test.pre, test.loop, test.post
        for j = 1,reps do
            collectgarbage()
            local t0   = clock()
            if pre then pre(count,irand,srand) end
            local t1 = clock()
            for i = 1,count do loop(i,irand,srand) end
            local t2 = clock()
            if post then post(count, irand, srand) end
            local t3 = clock()
            local tpre  = t1 - t0
            local tloop = t2 - t1
            local titer = 1e9 * tloop / count
            local tpost = t3 - t2
            lpre[#lpre+1] = tpre
            lloop[#lloop+1] = tloop
            lpost[#lpost+1] = tpost
            liter[#liter+1] = titer
        end
        printf("%s ( %d iterations, %d reps )\n",name,count, reps)
        for i = 1,reps do
            printf("%d:\t",i)
            if pre then printf("pre = %f s ( %E ns/item ),\t",lpre[i],1e9 * lpre[i] / count) end
            printf("loop = %f s ( %E ns/item )", lloop[i],1e9 * lloop[i]/count)
            if post then printf(",\tpost = %f s ( %E ns/item )",lpost[i], 1e9 * lpost[i]/count) end
            printf("\n")
        end
    end
end
