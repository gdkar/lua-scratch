
local q, qput, qget, qlen, qcount
local bit = require'bit'
local band = bit.band

local function pre(count,irand,srand)
    local Q = (require 'fl').TQ[1]
    q = Q()
    qput, qget, qlen, qcount = q.put, q.get, q.len, count
end

local function loop(i, irand, srand)
    local arg = irand[band(i,(2^18)-1)]
    if qlen() > 2^16 or band(arg,15) > 8 then
        qput(arg)
    else
        qget()
    end
end
local function post(count, irand, srand) end

return { pre  = pre, loop = loop, post = post, }
