local bind,bit = require'bind',require'bit'
local bind1 = bind.bind1
bind = bind.bind
local band = bit.band
local bound
local results = { }
local function pre(count,irand,srand)
    local function base(a,b,c,d)
        return a * ( b or 1 ) * (c or 1) * (d or 1)
    end
    bound = bind(base,1,2)
    for i=1,math.min(count,2^24-1) do results[i] = 0 end
end

local function loop(i,irand,srand)
    local arg = irand[band(i,2^24-1)]
    results[band(i,2^24-1)] = bound(arg,arg)
end
local function post(count,irand,srand)
end
return { pre = pre, loop = loop, post = post}
