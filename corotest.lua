#! /usr/bin/env luajit

local coro = coroutine
local create, resume, running, status,yield,wrap =  coro.create,coro.resume,coro.running,coro.status,coro.yield,coro.wrap
local function yielding(n)
    local ret = yield(n)
    print('yielding: ',ret)
    return ret
end

local function calling(arg)
    for _,a in ipairs(arg) do
        print("calling: ",yielding(a))
    end
end

print(...)
local function bind(fn,obj) return function(...) return fn(obj,...) end end

local co = create(calling)
local arg = {...}
local err, ret
while true do
    err, ret = resume(co, ret or arg)
    if not err then
        print(err,ret)
        return
    else
        print('main: ',ret,status(co))
    end
end
