local fl, vec, Q = require 'fl.flist', require 'fl.vec', require 'fl.flqueue'

local coro = coroutine
local yield,wrap,resume,create,status = coro.yield,coro.wrap,coro.resume,coro.create,coro.status

local function helper(...)
    yield()
    return helper(yield(...))
end

local fl, vec = require 'fl.flist', require 'fl.vec'
local Q = setmetatable({},{ __call = function(q, nq, size)
    local size = size or 0
    if size < 0 then size = 0 end
    local qlst = vec(size) 
    local dlst = { }
    for i = 1,nq do dlst[i] = { } end
    local qlen  = 0
    local flst = fl(size)
    local fput, fget = flst.put, flst.get
    local head = fget()
    local tail = head
    local stack = wrap(helper)
    local function put(item)
        local idx  = fget()
        for i = 1,nq do dlst[i][tail] = item end
        qlst[tail]  = idx
        tail        = idx
        qlen        = qlen + 1
    end
    local function get()
        if head ~= tail then
            local idx  = head
            stack(dlst[1][head])
            dlst[1][head] = nil
            for i=2,nq do
                stack(stack(),dlst[i][head])
                dlst[i][head] = nil
            end
            head,qlst[idx] = qlst[idx], 0
            fput(idx)
            qlen = qlen - 1
            return stack()
        end
    end
    local function peek()
        if head ~= tail then
            stack(dlst[1][head])
            for i=2,nq do stack(stack(),dlst[i][head]) end
        return data[head] end
    end
    local function qnext(q,idx)
        if idx == nil then idx = head end
        if idx ~= tail then return qlst[idx], data[idx] end
    end
    local function len() return qlen end
    local function iter() return qnext, nil, head end
    for i = 1,size do qlst[i] = 0
        for j = 1,nq do dlst[j][i] = 0 end
    end
    return setmetatable({ data = data, put  = put, peek=peek,get  = get, next = qnext, iter = iter, len = len },{ __len = len, __call = get})
end})
function Q.put(fl,idx) fl.put(idx) end
function Q.get(fl) return fl.get() end
function Q.len(fl) return fl.len() end
function Q.new(size) return Q(size) end


return Q
