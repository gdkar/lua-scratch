
local function bind(fn,...)
    if select('#',...) == 0 then return fn
    elseif select('#',...) == 1 then
        local a1 = ...
        return function(...) return fn(a1,...) end
    else
        local a1 = ...
        return bind(bind(fn,a1),select(2,...))
    end
end
local function bind1(fn,arg)
    return function(...) return fn(arg,...) end
end

return { bind = bind,bind1=bind1}
