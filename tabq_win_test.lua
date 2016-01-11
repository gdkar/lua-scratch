
local q, qput, qget, qlen, qcount
local items = { }

local function pre(count,irand,srand)
    local Q = require 'tabqueue'
    q = Q(count)
    qput, qget, qlen, qcount = q.put, q.get, q.len, count
    for i = 1,(count/16) do qput(srand[i]) end
end

local function loop(i, irand, srand) qput(qget()) end

local function post(count, irand, srand)
    for i=1,(count/16) do assert(srand[i] == qget()) end
end

return { pre  = pre, loop = loop, post = post, }
