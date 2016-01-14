
local q, qput, qget, qlen, qcount
local bit = require 'bit'
local band = bit.band
local sumlen = 0
local function pre(count,irand,srand)
    local Q = (require 'fl').MQ
    q = Q(2)
    qput, qget, qlen, qcount = q.put, q.get, q.len, count
end
local function loop(i, irand, srand)
    local arg = irand[i]
    if (qlen() < 2^18 and band(arg,0xf) > 6.5  ) then qput(arg,-arg) else qget(2) end
    sumlen = sumlen + qlen()
end

local function post(count, irand, srand) io.write(string.format("average queue size was %f\n", sumlen/count)) end

return { pre  = pre, loop = loop, post = post, }
