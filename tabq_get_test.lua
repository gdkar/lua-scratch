
local q, qput, qget, qlen, qcount
local items = { }

local function pre(count,irand,srand)
    local Q = require 'tabqueue'
    q = Q(count)
    qput, qget, qlen = q.put, q.get, q.len
    for i=1,count do qput(srand[i]) end
    qcount = count
end

local function loop(i, irand, srand)
    items[i] = qget()
end

local function post(count, irand, srand)
    for i=1,#items do assert(items[i] == srand[i]) end
end

return { pre  = pre, loop = loop, post = post, }
