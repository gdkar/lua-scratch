
local q, qput, qget, qlen, qcount

local function pre(count,irand,srand)
    local Q = require 'fl.flqueue'
    q = Q()
    qput, qget, qlen, qcount = q.put, q.get, q.len, count
    for i = 1,math.min(16,count/16) do qput(irand[i]) end
end

local function loop(i, irand, srand) qput(qget()) end

local function post(count, irand, srand) end

return { pre  = pre, loop = loop, post = post, }
