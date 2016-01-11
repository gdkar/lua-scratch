
local q, qput, qget, qlen, qcount

local function pre(count,irand,srand)
    local Q = require 'flqueue'
    q = Q(count)
    qput, qget, qlen, qcount = q.put, q.get, q.len, count
end

local function loop(i, irand, srand) qput(irand[i]) end

local function post(count, irand, srand)
    for i=1,count do assert(irand[i] == qget()) end
end

return { pre  = pre, loop = loop, post = post, }
