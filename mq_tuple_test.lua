
local q, qput, qget, qlen, qcount
local bit = require'bit'
local tuple = (require'cgtuple')[2]
local band = bit.band

local function pre(count,irand,srand)
    local Q = require 'flqueue'
    q = Q()
    qput, qget, qlen, qcount = q.put, q.get, q.len, count
end

local function loop(i, irand, srand)
    local arg = irand[i]
    if qlen() > 2^16 or band(arg,15) > 8 then
        qput(tuple(arg,arg))
    else
        qget()
    end
end
local function post(count, irand, srand) end

return { pre  = pre, loop = loop, post = post, }
