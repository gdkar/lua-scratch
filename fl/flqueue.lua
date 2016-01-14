local fl, vec = require 'fl.flist', require 'fl.vec'
local Q = setmetatable({},{ __call = function(q, size)
    local size = size or 0
    if size < 0 then size = 0 end
    local qlst = vec(size) 
    local data = { }
    local qlen  = 0
    local flst = fl(size)
    local fput, fget = flst.put, flst.get
    local head = fget()
    local tail = head

    local function put(item)
        local idx  = fget()
        data[tail]  = item
        qlst[tail]  = idx
        tail        = idx
        qlen        = qlen + 1
    end
    local function get()
        if head ~= tail then
            local idx,item  = head, data[head]
            data[idx],head,qlst[idx] = nil, qlst[idx], 0
            fput(idx)
            qlen = qlen - 1
            return item
        end
    end
    local function peek()
        if head ~= tail then return data[head] end
    end
    local function qnext(q,idx)
        if idx == nil then idx = head end
        if idx ~= tail then return qlst[idx], data[idx] end
    end
    local function len() return qlen end
    local function iter() return qnext, nil, head end
    for i = 1,size do qlst[i], data[i] = 0, 0 end
    return setmetatable({ data = data, put  = put, peek=peek,get  = get, next = qnext, iter = iter, len = len },{ __len = len, __call = get})
end})
function Q.put(fl,idx) fl.put(idx) end
function Q.get(fl) return fl.get() end
function Q.len(fl) return fl.len() end
function Q.new(size) return Q(size) end


return Q
