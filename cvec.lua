
local require = require
local ffi     = require'ffi'
local lib_path = "./lib/vec_lib.so"

local lib = ffi.load(lib_path)

local M = { }

ffi.cdef [[
typedef struct Vec {
    size_t  item_size;
    size_t  size;
    size_t  capacity;
    void   *data;
} Vec;

int  vec_create(Vec *v, size_t item_size, size_t initial_size);
void vec_destroy(Vec *v);
int  vec_reserve(Vec *v, size_t n);
int  vec_resize (Vec *v, size_t n);

typedef struct FList {
    int     size;
    int     fill;
    int     head;
    int    *data;
} FList;

int  flist_create(FList *v, int initial_size);
void flist_destroy(FList*v);
int  flist_get(FList *v);
int  flist_put(FList*v, int i);

void* malloc(size_t);
void  free(void*);
void *realloc(void*,size_t);

]]

local function iter(vec, idx)
    if idx and idx < #vec then
        idx = idx + 1
        return idx, vec[idx]
    end
end
local function ipairs_fn(t)
    return iter, t, 0
end
local cachedTypes = {}
setmetatable(cachedTypes, {__mode = 'v'})  -- weak values

local function new(ctype, initial_capacity, index, newindex, destructor)
    ctype = ffi.typeof(ctype)  -- support both ctype and C declaration
    local factory = cachedTypes[ctype]
    if not factory then
        local pointerType = ffi.typeof('$*', ctype)
        local methods = {}
        function methods:resize(n)
            local size = tonumber(self._v.size)
            if destructor and n < size then
                local ptr = ffi.cast(pointerType, self._v.data)
                for i = n + 1, size do
                    destructor(ptr[i - 1])
                end
            end
            if lib.vec_resize(self._v, n) < 0 then
                error('Out of memory')
            end
        end
        function methods:reserve(n)
            if lib.vec_resserve(self._v, n) < 0 then
                error('Out of memory')
            end
        end
        function methods:capacity() return self._v.capacity end
        -- a ffi metatype is faster than a table here...
        local meta_tp = {
            __new = function(ct, initial_capacity)
                initial_capacity = initial_capacity or 0
                local self = ffi.new(ct)
                if lib.vec_create(self._v, ffi.sizeof(ctype),
                                        initial_capacity) ~= 0 then
                    error('Failed to create vector')
                end
                return self
            end,
            __len = function(self)
                return tonumber(self._v.size)
            end,
            __ipairs = ipairs_fn,
            __pairs  = ipairs_fn
        }
        if destructor then
            function meta_tp.__gc (self)
                local ptr = ffi.cast(pointerType, self._v.data)
                local size = tonumber(self._v.size)
                for i = 1, size do
                    destructor(ptr[i - 1])
                end
                lib.vec_destroy(self._v)
            end
        else
            function meta_tp.__gc (self) lib.vec_destroy(self._v) end
        end
        if index then
            function meta_tp.__index(self, k)
                local kn = tonumber(k)
                if kn then
                    if kn >= 1 and kn <= self._v.size then
                        local v = ffi.cast(pointerType, self._v.data)[kn - 1]
                        return index(v)
                    else error('Index out of range') end
                else return methods[k] end
            end
        else
            function meta_tp.__index (self, k)
                local kn = tonumber(k)
                if kn then
                    if kn >= 1 and kn <= self._v.size then
                        local v = ffi.cast(pointerType, self._v.data)[kn - 1]
                        return v
                    else error('Index out of range') end
                else return methods[k] end
            end
        end
        function meta_tp.__newindex (self, k, v)
            local kn = tonumber(k)
            if kn then
                local ptr
                if kn >= 1 and kn <= self._v.size then
                    ptr = ffi.cast(pointerType, self._v.data)
                    if destructor then
                        destructor(ptr[kn - 1])
                    end
                elseif kn == self._v.size + 1 then
                    self:resize(kn)
                    ptr = ffi.cast(pointerType, self._v.data)
                else error('Index out of range') end
                if newindex then v = newindex(v) end
                ptr[kn - 1] = v
            else error('Invalid index') end
        end
        factory = ffi.metatype('struct { Vec _v; }',meta_tp)
        cachedTypes[ctype] = factory
    end
    return factory(initial_capacity)
end
M.new = new

local string_type = ffi.typeof('struct { char* data; size_t size; }')
local voidptr_type = ffi.typeof('void*')
local null = voidptr_type()

-- Create new_X functions for all numeric types

-- These get a 'u' prefix as well (so int8_t, uint8_t, etc)
local c99_int_types = { 'int8_t', 'int16_t', 'int32_t', 'int64_t' }

-- These get a 'unsigned ' prefix as well (so int, unsigned int, etc)
local int_types = { 'char', 'short', 'int', 'long' }

-- These are extra. Yes, signed char, as 'char', 'signed char', and
-- 'unsigned char' are actually three different types
local types = {'float', 'double', 'signed char'}

for _, t in ipairs(int_types) do
    table.insert(types, t)
    table.insert(types, 'unsigned ' .. t)
end
for _, t in ipairs(c99_int_types) do
    table.insert(types, t)
    table.insert(types, 'u' .. t)
end

for _, t in ipairs(types) do
    local ctype = ffi.typeof(t)
    t = t:gsub(' ', '_')
    M[t] = ctype

    local fn = 'new_' .. t
    M[fn] = function(initial_capacity)
        return new(ctype, initial_capacity, tonumber)
    end
end

local function create_ffi_string(src)
    local ptr = ffi.C.malloc(#src)
    if ptr == null then
        error('Failed to allocate memory')
    end
    ffi.copy(ptr, src, #src)
    return string_type(ptr, #src)
end

local function create_lua_string(src)
    return ffi.string(src.data, src.size)
end

local function destroy_ffi_string(src)
    ffi.C.free(src.data)
end

local function new_string(initial_capacity)
    return new(string_type, initial_capacity,
               create_lua_string, create_ffi_string, destroy_ffi_string)
end
M.new_string = new_string
return M
