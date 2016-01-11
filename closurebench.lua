local function Elem(prv,nxt, item)
    return function(key,val)
        if val == 'prv' then prv = key
        elseif val == 'nxt' then nxt = key
        elseif val == 'item' then item = key
        elseif key == 'prv' then return prv
        elseif key == 'nxt' then return nxt
        else return item
        end
    end
end

local function List(items)
    local head = nil
    local tail = nil
    for _, v in ipairs(items) do
        if not head then
            head = Elem(nil,nil,v)
            tail = head
        else
            local _head = head
            head = Elem(nil,head,v)
            _head(head,'prv')
        end
    end
    return function(op, item)
        if op == 'push_front' then
            local _head = head
            head = Elem(nil,head,item)
            _head(head,'prv')
        elseif op == 'push_back' then
            local _tail = tail
            tail = Elem(tail,nil,item)
            _tail(tail, 'nxt')
        elseif op == 'pop_front' then
            local _head = head
            head = head('nxt')
            return _head()
        elseif op == 'pop_back' then
            local _tail = tail
            tail = tail('prv')
            return _tail()
        end
    end
end

local list = List({'a'})
local clock = os.clock

local count = select(2,...) or 1024*1024
local start = clock()
for i=1,count do
    list('push_front',i)
end
local middle = clock()
for i=1,count do
    list('pop_back')
end
local finish = clock()

io.write(string.format("Pushing %d items took %f seconds ( %E ns / item)\n", count, middle-start,(middle-start)*1e9 / count))
io.write(string.format("Popping %d items took %f seconds ( %E ns / item)\n", count, finish-middle,(finish-middle)*1e9 / count))
