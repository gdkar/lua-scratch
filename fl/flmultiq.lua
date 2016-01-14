local fl, vec, Q = require 'fl.flist', require 'fl.vec', require 'fl.flqueue'

local make_q_src = function(nq)
    local vars = { }
    local function accesses(idx) 
        local accum = { }
        for i = 1, nq do accum[i] = "data" .. i .. "[" .. idx .. "]" end
        return table.concat(accum,",")
    end
    local temps = { }
    local inits = { }
    for i = 1,nq do vars[i], temps[i], inits[i] = "data" .. i, "tmp" .. i,"{ }" end
    vars = table.concat(vars, ",")
    temps = table.concat(temps, ",")
    inits = table.concat(inits,",")
    local src =  [[
        local nq, fl,vec  = ...
        local Q = setmetatable({},{ __call = function(q,size)
            local size = size or 0
            if size < 0 then size = 0 end
            local ]] ..vars .. [[ = ]] .. inits .. [[

            local qlen,qlst,flst = 0,vec(size),fl(size)
            local fput, fget,head, tail= flst.put, flst.get,flst.get()
            tail = head
            local function put(...)
                local idx = fget()
                ]] .. accesses("tail") .. [[ = ...
                qlst[tail] = idx
                tail       = idx
                qlen       = qlen + 1
            end
            local function get()
                if tail == head then return end
                local idx = head
                local ]] .. temps .. [[ = ]] .. accesses("idx") ..  [[

                ]] .. accesses("idx") .. [[ =  nil

                head, qlst[idx] = qlst[idx], 0
                fput(idx)
                qlen = qlen - 1
                return ]] ..  temps .. [[

            end
            local function pop()
                if head ~= tail then
                    local idx = head
                    ]] .. accesses("idx") .. [[ = nil
                    head = qlst[idx]
                    qlst[idx] = 0
                    fput(idx)
                    return true
                else return false end
            end
            local function peek()
                if head ~= tail then
                    return ]] .. accesses("head") ..[[
                end
            end
            local function qnext(q,idx)
                if idx == nil then idx = head end
                if idx ~= tail then
                    return qlst[idx], ]] .. accesses("idx") .. [[

                end
            end
            local function len() return qlen end
            local function width() return nq end
            local function iter() return get, nil  end
            local function scan() return qnext, nil end
            for i = 1,size do qlst[i], ]] .. accesses("idx") .. [[ =  0 ]] .. string.rep(", 0",nq) .. [[ end
            return setmetatable({ put = put, pop = pop, peek = peek, get = get, next = qnext, scan = scan, iter = iter, len = len },{__len = len, __call = get, __ipairs = scan })
        end,})
        function Q.put(fl,idx) fl.put(idx) end
        function Q.get(fl) return fl.get() end
        function Q.len(fl) return fl.len() end
        function Q.new(size) return Q(size) end

        return Q
]]
    return src
end
local queues = setmetatable({ Q },{ __index = function(qs, nq)
    local src = make_q_src(nq)
    local chunk, err = loadstring(src, "q"..nq)
    if not chunk then
        print(err)
        return
    end
    local status,Q     = pcall(chunk, nq, fl, vec)
    if not status then print(src, Q)
    else rawset(qs, nq, Q) end
    return rawget(qs,nq)
end,
})

return queues
