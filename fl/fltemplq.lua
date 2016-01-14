local fl, vec, Q = require 'fl.flist', require 'fl.vec', require 'fl.flqueue'

local template = require 'fl.template'
local queues = template.template_type( [[
local fl, vec, Q = require 'fl.flist', require 'fl.vec'
local Q = setmetatable({},{ __call = function(q, size)
    local size = size or 0
    if size < 0 then size = 0 end
    local qlst = vec(size) 
    local ${data} = ${:{}}
    local qlen  = 0
    local flst = fl(size)
    local fput, fget = flst.put, flst.get
    local head = fget()
    local tail = head

    local function put(...)
        local idx  = fget()
        ${data:data[tail]} = ... 
        qlst[tail]  = idx
        tail        = idx
        qlen        = qlen + 1
    end
    local function get()
        if head ~= tail then
            local idx = head
            local ${item} = ${data:data[head]}
            ${data:data[head]} = nil
            head,qlst[idx] = qlst[idx], 0
            fput(idx)
            qlen = qlen - 1
            return ${item}
        end
    end
    local function pop()
        if head ~= tail then
            head = qlst[head]
            return true
        else
            return false
        end
    end
    local function front()
        if head ~= tail then return ${data:data[head]} end
    end
    local function qnext(q,idx)
        if idx == nil then idx = head end
        if idx ~= tail then return qlst[idx], ${data:data[idx]} end
    end
    local function len() return qlen end
    local function iter() return qnext, nil, head end
    for i = 1,size do qlst[i], data[i] = 0, 0 end
    return setmetatable({ put  = put, front=front,get  = get,pop = pop, next = qnext, iter = iter, len = len },{ __len = len, __call = get})
end})
function Q.put(f,idx) f.put(idx) end
function Q.get(f) return f.get() end
function Q.len(f) return f.len() end
function Q.new(size) return Q(size) end


return Q ]],'templq')

return queues
