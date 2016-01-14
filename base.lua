#! /usr/bin/env luajit
local require = require
local ffi,bit = require'ffi',require'bit'
local to, new = ffi.typeof,ffi.new
local sprintf = string.format
local printf  = function(...) io.write(sprintf(...)) end
ffi.cdef [[
    int64_t rdtsc(void);
    double cpufreq(void);
    double getclock(void);
]]
local tsc = ffi.load("./tsc.so")
--local rdtsc,cpufreq,clock = tsc.rdtsc,tsc.cpufreq,tsc.getclock
local clock = function() return tonumber(tsc.rdtsc() ) end
--local clock = os.clock

local count = tonumber(select(1,...) or 2^16)
local reps  = tonumber(select(2,...) or 16)
local tests = {select(3,...)}
math.randomseed(clock())
local irand = ffi.new("int[?]", math.min(count+ 1,2^24))
local srand = { }
do
    for i = 1,math.min(count,2^24)  do irand[i] = math.random(2^24-1) end
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
        local spre, sloop, siter, spost = 0, 0, 0, 0
        local pre, loop, post = test.pre, test.loop, test.post
        collectgarbage()
        for j = 1,reps do
            local t0   = clock()
            if pre then pre(count,irand,srand) end
            local t1 = clock()
            for i = 1,count do loop(i,irand,srand) end
            local t2 = clock()
            if post then post(count, irand, srand) end
            local t3 = clock()
            local tpre  = t1 - t0
            local tloop = t2 - t1
            local titer = tloop / count
            local tpost = t3 - t2
            lpre[#lpre+1] = tpre
            lloop[#lloop+1] = tloop
            lpost[#lpost+1] = tpost
            liter[#liter+1] = titer
            spre = spre + tpre
            sloop = sloop + tloop
            siter = siter + titer
            spost = spost + tpost
        end
        printf("%s ( %d iterations, %d reps )\n",name,count, reps)
        if pre then printf("\tpre = %f s ( %E clocks/item )\n",spre/reps,spre/reps / count) end
        printf("\tloop = %f s ( %E clocks/item, %E ns/item )\n", sloop/reps, sloop/reps/count, sloop / reps / count / tsc.cpufreq() * 1e9)
        if post then printf("\tpost = %f s ( %E clocks/item )\n",spost/reps, spost/reps/count) end
        printf("\n")
    end
end
