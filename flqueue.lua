local cvec = require 'cvec'
local fl = require'flffi'
local vec = cvec.new_int
--local fl,vec = require 'flffi', (require 'cvec').new_int
local Q = setmetatable({},{ __call = function(q, size)
    local size = size or 1
    if size < 64 then size = 64 end
    local flst = fl(size)
    local qlst = vec(size)
    qlst:resize(size)
    local data = { }

    local head = flst.get() -- fget()
    local tail = head
    local qlen  = 0
    local function put(item)
        local idx  = flst.get() -- fget()
        data[idx],qlst[tail],tail= item, idx, idx
        qlen       = qlen + 1
    end
    local function get()
        if head ~= tail then
            local idx, item = head,data[head]
            data[head],head,qlst[head] = nil, qlst[head], 0
            flst.put(idx)
--            fput(idx)
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
