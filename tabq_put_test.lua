
local q, qput, qget, qlen, qcount
local items = { }

local function pre(count,irand,srand)
    local Q = require 'tabqueue'
    q = Q(count)
    qput, qget, qlen, qcount = q.put, q.get, q.len, count
end

local function loop(i, irand, srand) qput(srand[i]) end

local function post(count, irand, srand)
    for i=1,count do assert(srand[i] == qget()) end
end

return { pre  = pre, loop = loop, post = post, }
