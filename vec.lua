local require = require
local ffi, bit = require 'ffi', require 'bit'

local new, typeof, cdef, cast, sizeof, gc = ffi.new,ffi.typeof, ffi.cdef, ffi.cast,ffi.sizeof, ffi.gc

cdef [[
typedef struct Vec {
    int *ptr;
    size_t  vsize;
    size_t  dsize;
}Vec;
void *malloc(size_t);
void *realloc(void*,size_t);
void  free(void*);
]]
local free = ffi.C.free
local malloc = ffi.C.malloc
local realloc = ffi.C.realloc
local sizeof_int = sizeof("int")
local intp       = typeof("int*")
local function resize(self,size)
    local dsize = self.dsize
    if size > dsize then
        if dsize == 0 then dsize = 16 end
        while size > dsize do dsize = dsize * 2 end
        local ptr = ffi.cast(intp,realloc(self.ptr,dsize * sizeof_int))
        if ptr then
            self.ptr = ptr
            self.dsize = dsize
        end
    end
end
local Vec = ffi.metatype(typeof("Vec"),{
    __new = function(vec,sz)
        local sz  = sz or 0
        local vsz = sz
        if sz < 16 then sz = 16 end
        local self = ffi.new(vec)
        self.vsize = vsz
        self.dsize =  0
        resize(self,vsz)
        return self
    end,
    __len = function(self)
        return self.vsize
    end,
    __index = function(self, key)
        local idx = key - 1
        if idx < self.vsize then return self.ptr[idx] end
    end,
    __newindex = function(self,key,val)
        local idx = key - 1
        if idx >= self.vsize then
            resize(self, idx + 1)
            if idx < self.dsize then
                self.vsize = idx + 1
            end
        end
        if 0 <= idx and idx < self.dsize then
            self.ptr[idx] = val
        end
    end,
    __gc = function(self)
        free(self.ptr)
        self.ptr = nil
        self.vsize = 0
        self.dsize = 0
    end
})

return Vec
