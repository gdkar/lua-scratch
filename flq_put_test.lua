
local q, qput, qget, qlen, qcount
local band = (require'bit').band
local function pre(count,irand,srand)
    local Q = require 'flqueue'
    q = Q()
    qput, qget, qlen, qcount = q.put, q.get, q.len, count
end

local function loop(i, irand, srand) qput(irand[band(i,2^20-1)]) end

local function post(count, irand, srand)
    for i=1,count do assert(irand[band(i,(2^20)-1)] == qget()) end
end

return { pre  = pre, loop = loop, post = post, }
