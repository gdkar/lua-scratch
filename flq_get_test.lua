
local q, qput, qget, qlen, qcount

local function pre(count,irand,srand)
    local Q = require 'flqueue'
    q = Q()
    qput, qget, qlen = q.put, q.get, q.len
    for i=1,count do qput(irand[i]) end
    qcount = count
end

local function loop(i, irand, srand)
    qget()
end

local function post(count, irand, srand) end

return { pre  = pre, loop = loop, post = post, }
