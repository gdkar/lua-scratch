
local function split(delimiter, text)
    if delimiter == "" then return { text } end
    if #text == 0 then return { } end
    local lst = {}
    local pos = 1
    while true do
        local first, last = text:find(delimiter,pos)
        if first then
            lst[#lst+1] = text:sub(pos,first-1)
            pos = last + 1
        else
            lst[#lst+1] = text:sub(pos)
            break
        end
    end
    return lst
end
local function template( code )
    local function eval(n)
        local function anon(str)
            return string.rep(str, n, ", ")
        end
        local function name_only(str)
            local tab = { }
            local pos = 1
            for i=1,n do
                if i > 1 then
                    tab[pos] = sep or ", "
                else
                    tab[pos] = " "
                end
                tab[pos + 1] = str
                tab[pos + 2] = "_"
                tab[pos + 3] = tostring(i)
                pos = pos + 4
            end
            tab[pos] = " "
            return table.concat(tab)
        end
        local function name_rep(names,rest,sep)
            local tab = { }
            local pos = 1
            for i = 1,n do
                tab[pos] = rest
                for j=1,#names do
                    local name = names[j]
                    local nname = name .. "_" .. i
                    tab[pos] = tab[pos]:gsub(name, nname)
                end
                pos = pos + 1
            end
            return table.concat(tab, sep or ", ")
        end
        local function dispatch(m)
            if m == "{#}" then return tostring(n) end
            local name, rest = m:match("{([^:]*):(.*)}")
            local sep
            if rest and rest ~= "" then
                local pos = 1
                local names = { }
                while true do
                    local first, last = name:find(",",pos)
                    if first then
                        if first - 1 > pos then
                            names[#names+1] = name:sub(pos,first - 1)
                        end
                        pos = last + 1
                    else
                        first, last = name:find("|",pos)
                        if first then
                            names[#names+1] = name:sub(pos,first - 1)
                            sep = name:sub(first + 1)
                            if sep == "" then sep = nil end
                        else
                            names[#names+1] = name:sub(pos)
                            if names[#names] == "" then names[#names] = nil end
                        end
                        break
                    end
                end
                if #names > 0 then
                    return name_rep(names,rest,sep)
                elseif rest and rest ~= "" then
                    return anon(rest,sep)
                end
            else
                name = m:match("{(%w+)}")
                if name then return name_only(name) end
            end
            return ""
        end
        return code:gsub("%$(%b{})",dispatch)
    end
    return eval
end

local function template_type(code,name)
    local eval = template(code)
    return setmetatable({ }, { __index = function(tp, n)
        if type(n) == "number" and n > 0 then
            local src, msg = pcall(eval,n)
            if not src then print(msg)
            else src = msg end
            local ret
            ret, msg = loadstring(src, name .. "<" .. n .. ">")
            if ret then
                ret,msg = pcall(ret)
                if ret then
                    rawset(tp,n,msg)
                    return rawget(tp,n)
                end
            end
            print(msg, src)
        end
    end,
    __call = function(tp, n, ...)
        local fn = tp[n]
        if fn then return fn(...) end
    end})
end

return {
    template = template,
    template_type = template_type,
    split    = split,
}
