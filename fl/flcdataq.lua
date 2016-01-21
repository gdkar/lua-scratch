local fl, vec = require 'fl.flist', require 'fl.vec'
local Q = setmetatable({},{ __call = function(q, ctype, size)
    local size = size or 0
    if size < 0 then size = 0 end
    local qlst = vec(size) 
    local data = { }
    local qlen  = 0
    local flst = fl(size)
    local fput, fget = flst.put, flst.get
    local head = fget()
    local tail = head

    local function put(...)
        for i = 1,select('#',...) do
            local item = select(i,...)
            local idx  = fget()
            data[tail],qlst[tail],tail  = item,idx,idx
            qlen        = qlen + 1
        end
    end
    local function get()
        if head ~= tail then
            fput(head)
            local item  = data[head]
            data[head],head,qlst[head] = nil, qlst[head], 0
            qlen = qlen - 1
            return item
        end
    end

    local function pop()
         if head ~= tail then
            fput(head)
            data[head],head,qlst[head] = nil, qlst[head], 0
            qlen = qlen - 1
            return true
        end
    end
    local function front()
        if head ~= tail then return data[head] end
    end
    local function drop(item)
        if not item then return end
        if front() == item then return pop() end
        local idx, nxt = head, qlst[head]
        while nxt ~= tail do
            if data[nxt] == item then
                qlst[idx],data[nxt], qlst[nxt] = qlst[nxt],nil, 0
                qlen = qlen - 1
                return true
            else idx,nxt = nxt,qlst[nxt] end
        end
    end
    local function remove(item)
        if not item then return end
        local found = 0
        while front() == item do
            data[head],head,qlst[head] = nil, qlst[head],0
            found = found + 1
        end
        local idx, nxt = head, qlst[head]
        while nxt ~= tail do
            if data[nxt] == item then
                qlst[idx] = qlst[nxt]
                data[nxt], qlst[nxt] = nil, 0
                qlen = qlen - 1
                found = found + 1
            else idx,nxt = nxt,qlst[nxt] end
        end
        return found
    end
    local function qnext(q,idx)
        if idx == nil then idx = head end
        if idx ~= tail then return qlst[idx], data[idx] end
    end
    local function len() return qlen end
    local function iter() return qnext, nil, head end
    for i = 1,size do qlst[i], data[i] = 0, 0 end
    return setmetatable({ data = data, drop=drop, put  = put, front=front,get  = get, next = qnext, iter = iter, len = len },{ __len = len, __call = get})
end})
function Q.put(fl,idx) fl.put(idx) end
function Q.get(fl) return fl.get() end
function Q.len(fl) return fl.len() end
function Q.new(size) return Q(size) end


return Q
