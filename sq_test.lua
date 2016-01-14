
local q, qput, qget, qlen, qcount
local ops = { }
local args = { }
local peak = 0
local bit = require 'bit'
local band = bit.band
local coro = coroutine
local yield,wrap,resume,create,status = coro.yield,coro.wrap,coro.resume,coro.create,coro.status

local function helper(...)
    yield()
    return helper(yield(...))
end

local function pre(count,irand,srand)
    local Q = (require 'fl').Q
    q = Q(0)
    qput, qget, qlen,qpop, qcount = q.put, q.get, q.len, q.pop,count
--    qget = wrap(function() for a,b in q do yield(a,b) end end)
end
local function loop(i, irand, srand)
    local arg = irand[band(i,2^24-1)]
    if (qlen() < 2^16 and band(arg,0xf) > 7  ) then qput(arg) else qget() end
end

local function post(count, irand, srand) io.write(string.format("Peak queue size was %d\n", peak)) end

return { pre  = pre, loop = loop, post = post, }
