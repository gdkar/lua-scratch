-- Incremental quicksort, hopefully showing that quicksort
-- fundamentally uses a binary tree as an intermediate
-- (but deforested) data structure.
--
-- This implementation is lazy; if you ask for element
-- i of an array, it only sorts the array as much as
-- necessary to produce the element at i. The intermediate
-- result is maintained by the use of closures, rather
-- than explicitly in a binary tree; at each recursion
-- we create a new closure to represent the state of
-- the computation at that segment of the tree.
--
-- The "binary tree" is always complete; that is, each
-- element in the tree is either a Leaf, representing a
-- non-empty unsorted range of the vector, or a Node,
-- which has a left and right Tree and a non-empty
-- sorted range (in between left and right). In effect,
-- partioning is down on the way down, and merging on
-- the way up.

-- TODO: Create versions of sort3, partition and inssort
-- which take a sortation function; use this to efficiently
-- implement generalised sortation to match table.sort.

-- Note: Uncomment all the blocks labelled "Inserted for
-- tree viewing" (by removing the [[) and you can get
-- tree visualizations by calling getter"".

local function sort3(a, b, c)
  if a < b then
    if b < c then return a, b, c
    elseif a < c then return a, c, b
    else return c, a, b
    end
  elseif a < c then return b, a, c
  elseif b < c then return b, c, a
  else return c, b, a
  end
end


-- Based on Sedgwick, of course.
-- Requires that high - low >= 2
-- Rearranges v in place and returns start, fin such that:
--    v[i] <= v[start]  if low <= i < start
--    v[i] >= v[start]  if fin <= i < high
--    v[i] == v[start]  if start <= i < fin
--  and
--    low < start < fin < high

local bit = require 'bit'
local shr = bit.rshift
local function div2(x) return shr(x,1) end
local floor = math.floor
local function partition(v, low, high)
  local mid = div2(low + high)
  local pivot
  local i, j = low, high-2
  v[low], pivot, v[high-1] = sort3(v[low], v[mid], v[high-1])
  v[mid], v[j] = v[j], pivot
  while true do
    repeat i = i + 1 until v[i] >= pivot
    repeat j = j - 1 until v[j] <= pivot
    if i <= j then
      v[i], v[j] = v[j], v[i]
    else
      v[i], v[high-2] = pivot, v[i]
      return j+1, i+1
    end
  end
end

-- Insertion sort, used for small ranges
-- Sorts elements [low, high) of v, in place.
-- Returns nil, high, low (to be compatible with partialsort)
local inssort
do
    local tmp = { }
    function inssort(v, low, high)
        for i = 1,high - low do tmp[i] = v[low + i] end
        for i = high-low+1,#tmp do tmp[i] = nil end
        table.sort(tmp)
        for i = 1,high - low do v[low+i] = tmp[i] end
        return nil,high,low
    end
--[[    for i = low+1, high-1 do
        local elt = v[i]
        if elt < v[low] then
        for j = i-1, low, -1 do v[j+1] = v[j] end
        v[low] = elt
        else
        local j = i-1
        while elt < v[j] do v[j+1] = v[j]; j = j - 1 end
        v[j+1] = elt
        end
    end
    return nil, high, low
    end]]
end
--[[ Inserted for tree viewing
local function prep(s)
  return "+"..("-"):rep(#s - 1)
end
local function ishow(i)
  return i:gsub("[|+]%s+$", prep)
end
--]]-- End of insert

-- lazysort returns an accesor function of one parameter:
--
--   getter = lazysort(v, low, high)
--
-- such that:
--   val = getter(i)
-- returns the value with which would have index i in the
-- sorted vector v, in the range [low, high) which defaults
-- to [1, #v + 1)
-- 
-- After a call to getter(i), it is guaranteed that
--   v[j] <= v[i] for low <= j < i
--   v[i] <= v[j] for i <= j < high
-- Moreover, any previous such guarantees remain in force (i.e.
-- the vector is successively more sorted).
-- 
-- For example, to compute the mean of each quintile in a vector,
-- one could use the following:
--
-- function quintile_means(v)
--   local getter = lazysort(v)
--   local retval = {}
--   local start = 1
--   for i = 1, 5 do
--     local fin = math.ceil((#v * i) / 5)
--     local sum = getter(fin) 
--     -- equivalent to: sum = sorted_v[fin]
--     -- v is now partitioned such that the i'th quintile
--     -- is in [start, fin]
--     for j = fin-1, start, - 1 do sum = sum + v[j] end
--     retval[i] = sum / (fin - start + 1)
--     -- Get ready for the next iteration
--     start = fin + 1
--   end
--   return retval
-- end
--
-- Incompletely sorted ranges of the tree are represented by closures
-- whose interface is:
--  function(i, low, high) ==> closure, low', high'
-- where i is in the range [low, high);
-- 
-- One such function is partialsort, defined below.
--
-- On return:
--   The vector is sorted in ranges: [low, low') and [high, high')
-- and
--   The closure obeys the same interface, and can be
--   called with (i, low', high') where low' <= i < high'
--   in order to continue the sort.
-- If a closure completely sorts its range, it returns
-- nil, high, low: while it is true that nil is not strictly
-- speaking a closure, the above rule does not allow it to
-- be called, since there is no qualifying value of i.

function lazysort(v, low, high)
  low = low or 1
  high = (high or #v) + 1
  
  local function partialsort(i, low, high)
    if type(i)=="string" then
      return print(("%sLeaf [%d, %d) Unsorted"):format(ishow(i), low, high))
    end
    -- if the segment is "small", just sort it
    if high - low <= 63 then
      return inssort(v, low, high)
    end
    -- Make the new "node" (i.e. closure)
    -- Note that this is nothing more than the quicksort recursion:
    --   start, fin = partition(v, low, high);
    --   return quicksort(v, low, start)
    --          ++ range(v, start, fin)
    --          ++ quicksort(v, fin, high)
    -- Except that the append is done "in place" and the recursion
    -- is done "on demand"
    
    local start, fin = partition(v, low, high)
    local left, right = partialsort, partialsort

    -- The main work of the closure is to merge sorted Nodes:
    local function self(i, low, high)
      --[[ Inserted for tree viewing
      if type(i)=="string" then
        print(("%sNode [%d, %d)"):format(ishow(i), low, high))
        i = i:gsub("%+", " ")
        left(i.."| ", low, start)
        print(("%s+-Sorted [%d, %d)"):format(i, start, fin))
        return right(i.."+ ", fin, high)
      end
      --]]-- End of insert
      if i < start then
        left, low, start = left(i, low, start)
        if not left then -- completely sorted
          return right, fin, high
        end
      elseif i >= fin then
        right, fin, high = right(i, fin, high)
        if not right then
          return left, low, start
        end
      end
      return self, low, high
    end
    -- Now we need to call the new closure to continue the sort
    return self(i, low, high)
  end
  
  -- The top-level lazy getter is the inverse of a Tree: it has
  -- one unsorted range sandwiched in between two sorted ranges.
  -- Initially the sorted ranges are empty (the only place where
  -- empty ranges are allowed) and the unsorted range is the whole
  -- vector.
  local middle = partialsort
  return function(i)
    --[[ Inserted for tree viewing
    if type(i) == "string" then
      print(i.."Root")
      print(("%s+-Sorted [%d, %d)"):format(i, 1, low))
      middle(i.."| ", low, high)
      return print(("%s+-Sorted [%d, %d)"):format(i, high, #v))
    end
    --]]-- End of insert
    if i >= low and i < high then
      middle, low, high = middle(i, low, high)
    end
    return v[i]
  end
end



if select('#',...) then
  function intervalmeans(getter, v, n)
    local retval = {}
    local start = 1
    for i = 1, n do
      local fin = math.ceil((#v * i) / n)
      local sum = getter(fin) 
      for j = fin-1, start, - 1 do sum = sum + v[j] end
      retval[i] = sum / (fin - start + 1)
      start = fin + 1
    end
    return retval
  end
  local sys = require'syscall'
  local function clock()
        return sys.clock_gettime(sys.c.CLOCK.REALTIME).time
  end
  local random = math.random
  local rseed  = tonumber(select(4,...) or clock())
  local function maketest(nval, maxval)
    -- always generate the same random table
    math.randomseed(rseed)
    local test = {}
    for i = 1, nval do test[i] = (random() + random()) * maxval * 0.5 end
    return test
  end
  
  local function time(desc)
    return function(func, ...)
      io.stderr:write("Test "..desc.." ...")
      local now = clock()
      local retval = func(...)
      io.stderr:write(("%E seconds\n"):format(clock() - now))
      return retval
    end
  end
  
  function bench(which, nval, maxval)
    local test = maketest(nval, maxval)
    local dispatch = { 
        builtin = function()
            time "Built-in sort" (
            table.sort, test
            )
        end,
        complete = function()
            time "Complete sort" (
            function()
                local getter = lazysort(test)
                for i = 1, nval do getter(i) end
            end
            )
        end
        }
        dispatch[which]()
    end
    if select(1,...) == 'all' then
        for _, t in ipairs{ "builtin", "complete" } do
            os.execute("/usr/bin/time -v luajit lazysort.lua " .. t .. " " .. table.concat({select(2,...),rseed}, " ") .. " ")
        end
    else
        bench(select(1,...),tonumber(select(2,...) or 1e4), tonumber(select(3,...) or 1957))
    end
end
