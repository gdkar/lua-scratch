
local q, qput, qget, qlen, qcount
local rb = require'ringbuf'
local bit = require'bit'
local band = bit.band
local ffi = require'ffi'
local elem = ffi.typeof("struct { int first; int second; }")
local function pre(count,irand,srand)
    q = rb(elem,2048)
    qput, qget, qlen, qcount = q.put, q.get, q.len, count
    for i = 1,math.min(16,count/16) do q:push_back({i,irand[i]}) end
end

local function loop(i, irand, srand)
    local arg = irand[band(i,(2^18)-1)]
    if q:front_len() < 16 then
        q:pop_mid()
    end
    if (q:total_len() < 32 or band(arg,15) > 8) then
        local front = q:front()
        front.first = i
        front.second = arg
        q:push_back(front)
    else
        q:pop_front()
    end
end

local function post(count, irand, srand) end

return { pre  = pre, loop = loop, post = post, }
