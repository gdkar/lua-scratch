local ffi = require'ffi'
local typeof, new = ffi.typeof, ffi.new
local typ = typeof("struct { int a; int b; int64_t c;}")
local item = typ()
local pstr= "$ *"
local astr= "$ *[1]"

local function pre(count,irand,srand)
end

local function loop(i,irand,srand)
    local ptr = typeof(pstr, typ)(item)
end
local function post(count,irand,srand)
end
return { pre = pre, loop = loop, post = post}
