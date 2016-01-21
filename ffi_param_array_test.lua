local ffi = require'ffi'
local typeof, new = ffi.typeof, ffi.new
local typ = typeof("struct { int a; int b; int64_t c;}")
local item = typ()
local pstr= "$ *"
local astr= "$ *[1]"
local typs= setmetatable({ }, { __call = function(t,ct)
    ct = typeof(ct)
    local cache = rawget(t,ct)
    if cache then return cache end
    local atype = typeof(astr,ct)
    rawset(t,ct,atype)
    return atype
end})
local function pre(count,irand,srand)
    local array = typs(item)(item)
    assert(item == array[0])
end

local function loop(i,irand,srand)
    local array = typs(item)(item)
end
local function post(count,irand,srand)
    local size = 0
    for _,__ in pairs(typs) do size = size + 1 end
    io.write(string.format("size fo typs is %d\n",size))
end
return { pre = pre, loop = loop, post = post}
