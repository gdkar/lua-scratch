local bind,bit = require'bind',require'bit'
local bind1 = bind.bind1
bind = bind.bind
local band = bit.band
local bound
local results = { }
local function pre(count,irand,srand)
    local function base(...)
        local accu = 0
        for i=1,select('#',...) do accu = accu * select(i,...) end
        return accu
    end
    bound = base
    for i=1,math.min(count,2^24-1) do results[i] = 0 end
end

local function loop(i,irand,srand)
    local arg0 = irand[band(i*2,2^24-1)]
    local arg1 = irand[band(i*2+1,2^24-1)]
    bound = bind(bound,arg0)
    results[band(i,2^24-1)] = bound(arg1)
end
local function post(count,irand,srand)
end
return { pre = pre, loop = loop, post = post}
