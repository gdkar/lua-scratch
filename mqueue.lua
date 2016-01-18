local fl,vec = require 'flffi', require 'ffivec'

local cg = require'CodeGen'
local varmatch = "%$(%b{})"
local function cutvar(count)
    return function(m)
        local a,b = string.match(m,"{(%w*):?(.*)}")
        local conc= { }
        print(a,b)
        if b ~="" then
            if a == "" then
                for i = 1,count do conc[i] = b end
            else
                for i = 1,count do
                    sub = (a .. "_" .. tostring(i))
                    conc[i] = string.gsub(b,a,sub)
                end
            end
        else
            for i = 1,count do
                conc[i] = (a .. "_" .. tostring(i))
            end
        end
        return table.concat(conc,", ")
    end
end
local function repvar(s, m)
    return s:gsub(varmatch,cutvar(m))
end
print(repvar("${data} ${data:data[idx]} ${:nil}",4))
local Q = setmetatable({},{ __call = function(q, size)
    local size = size or 1
    if size < 64 then size = 64 end
    local flst = fl(size)
    local fput,fget = flst.put, flst.get
    local qlst = vec(size)
    local data = { }

    local head = fget()
    local tail = head
    local qlen  = 0
    local function put(item)
        local idx  = fget()
        data[idx],qlst[tail],tail= item, idx, idx
        qlen       = qlen + 1
    end
    local function get()
        if head ~= tail then
            local idx, item = head,data[head]
            data[head],head,qlst[head] = nil, qlst[head], 0
            fput(idx)
            qlen = qlen - 1
            return item
        end
    end
    local function front() if head ~= tail then return data[head] end end
    local function pop()
        if head ~= tail then head,data[head],qlst[head] = qlst[head],nil,0 end
    end
    local function len() return qlen end
    for i = 1,size do qlst[i], data[i] = 0, 0 end
    return setmetatable({ data = data, put  = put, get  = get, len = len, pop = pop, front = front },{ __len = len })
end})

return Q
