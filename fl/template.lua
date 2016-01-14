
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
                    tab[pos] = ", "
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
        local function name_rep(name,rest)
            local tab = { }
            local pos = 1
            for i = 1,n do
                local nname = name .. "_" .. i
                tab[pos] = rest:gsub(name, nname)
                pos = pos + 1
            end
            return table.concat(tab, ", ")
        end
        local function dispatch(m)
            if m == "{#}" then return tostring(n) end
            local name, rest = m:match("{(%w*):(.*)}")
            if rest then
                if name ~= "" then
                    return name_rep(name,rest)
                elseif rest and rest ~= "" then
                    return anon(rest)
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
            local src = eval(n)
            local ret, msg = loadstring(src, name .. "<" .. n .. ">")
            if ret then rawset(tp, n, ret())
                return rawget(tp,n)
            end
            print(msg)
        end
    end, })
end

return {
    template = template,
    template_type = template_type,
    split    = split,
}
