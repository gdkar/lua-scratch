function all(n, ...) return ... end     -- return all elements in tuple
function size(n) return n end           -- return size of tuple
function first(n,e, ...) return e end     -- return first element in tuple
function second(n,_,e, ...) return e end  -- return second element in tuple
function third(n,_,_,e, ...) return e end -- return third element in tuple
local nthf = setmetatable({first, second, third},
{
    __index =  function (n)
    rawset(nthf,n,function(...) return select(n+1, ...) end)
    return nthf[n]
end, } )

local function make_tuple_equals(n)
  local ta, tb, te = {}, {}, {}
  for i=1,n do
    ta[#ta+1] = "a" .. i
    tb[#tb+1] = "b" .. i
    te[#te+1] = "a" .. i .. "==b" .. i
  end
  local alist = table.concat(ta, ",")
  if alist ~= "" then alist = "," .. alist end
  local blist = table.concat(tb, ",")
  if blist ~= "" then blist = "," .. blist end
  local elist = table.concat(te, " and ")
  if elist ~= "" then elist = "and " .. elist end
  local s = [[
    local t, n1 %s = ...
    local f = function(n2 %s)
      return n1==n2 %s
    end
    return t(f)
  ]]
  s = string.format(s, alist, blist, elist)
  return assert(loadstring(s))
end

local cache = {}
function equals(t)
  local n = t(size)
  local f = cache[n]; if not f then
    f = make_tuple_equals(n)
    cache[n] = f
  end
  return function(...) return f(t, ...) end
end

local function equals2(t1, t2)
  return t1(equals(t2))
end

local ops = {
  ['#'] = size,
  ['*'] = all,
}
local ops2 = {
  ["number"]   = function(x) return nthf[x] end,
  ["function"] = function(x) return x end,
  ["string"]   = function(x) return ops[x] end
}

local function tuple_ctor(n)
  local ts = {}
  for i=1,n do ts[#ts+1] = "a" .. i end
  local slist = table.concat(ts, ",")
  local c = slist ~= "" and "," or ""
  local s =
    [[return function(...)
        local ]] .. slist .. [[ = ... 
        return function() return ]] .. slist ..[[ end
    end]]
  return assert(loadstring(s))()
end

local tuples = setmetatable({}, { __index = function(t,n)
    t[n] = tuple_ctor(n)
    return t[n]
end})
return tuples
