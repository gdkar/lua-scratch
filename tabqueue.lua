
local Q = setmetatable({},{ __call = function(q,size)
    local data = { }
    local head = 1
    local tail = 1
    local function put(item)
        data[tail] = item
        tail = tail + 1
    end
    local function get()
        local item
        if head < tail then
            item,data[head] = data[head],nil
            head = head + 1
        end
        return item
    end
    local function len() return tail - head end
    return setmetatable({ data = data, put  = put, get  = get, len = len },{ __len = len })
end})

return Q
