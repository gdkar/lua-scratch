
local q, qput, qget, qlen, qcount
local bit = require'bit'
local band = bit.band
local ffi = require'ffi'
local tab  = { }
local tab1 = setmetatable({ }, { __mode = 'kv'})
local order = 10
local function pre(count,irand,srand)
    for i = 1,2^order do
        local rand = srand[i]
        tab[rand] = function(x) return x .. rand  end
        tab1[tab[rand]] = i
    end
end

local function loop(i, irand, srand)
    local idx = band(2^order-1,irand[band(i,2^18-1)]) + 1
    local arg = tab[srand[idx]]
    tab1[arg] = tab1[arg] + 1
end

local function post(count, irand, srand) end

return { pre  = pre, loop = loop, post = post, }
