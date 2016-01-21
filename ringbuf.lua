local require = require
local ffi = require'ffi'
local new,gc,typeof,istype,metatype,cast,sizeof = ffi.new,ffi.gc,ffi.typeof,ffi.istype,ffi.metatype,ffi.cast,ffi.sizeof
local bit = require'bit'
local band = bit.band
local RingBuf = { }
local TypeCache = { }
local RingBuf_meth = { }
local RingBuf_mt = {
__index = function(self,key)
    if type(key) == 'number' then
        if 0 < key and key <= self.siz then
            local off = band(self.mask, self.beg + key - 1)
            return self.data[off]
        end
    else
        return rawget(RingBuf_meth,key)
    end
end,
__newindex = function(self,key,val)
    if type(key) == 'number' then
        if 0 < key and key <= self.siz then
            local off = band(self.mask,self.beg + key - 1)
            self.data[off] = val
            end
    end
end,
__len = function(self)
    return band(self.bidx - self.fidx,self.mask)
end,
__metatable = { } }
setmetatable(RingBuf, { __call = function(rb,ct,siz,...)
    local cta = TypeCache[ct]
    if not cta then
        local _ct
        if type(ct) == 'string' then
            _ct = typeof(ct)
        else
            _ct = ct
        end
        cta = typeof("$ [?]",_ct)
        TypeCache[ct] = cta
        TypeCache[_ct] = cta
    end
    local self = setmetatable(
    {
        data = cta(siz),
        fidx = 0,
        midx= 0,
        bidx = 0,
        siz = siz,
        mask = siz-1
    }, RingBuf_mt)
    return self
end,})
function RingBuf_meth.front(self)
    if self.midx > self.fidx then
        return self.data[band(self.fidx,self.mask)]
    end
end
function RingBuf_meth.mid(self)
    if self.midx > self.fidx then
        return self.data[band(self.midx - 1,self.mask)]
    end
end
function RingBuf_meth.back(self)
    if self.bidx > self.midx then
        return self.data[band(self.bidx - 1,self.mask)]
    end
end
function RingBuf_meth.pop_front(self)
    if self.fidx < self.bidx then
        self.fidx = self.fidx + 1
    end
end
function RingBuf_meth.pop_mid(self)
    if self.midx < self.bidx then
        self.midx = self.midx + 1
    end
end
function RingBuf_meth.push_back(self,val)
    if self.bidx < self.fidx + self.siz then
        self.data[band(self.mask,self.bidx)] = val
        self.bidx = self.bidx + 1
    end
end
function RingBuf_meth.front_len(self) return self.midx - self.fidx end
function RingBuf_meth.back_len(self) return self.bidx - self.midx end
function RingBuf_meth.total_len(self) return self.bidx - self.fidx end

return RingBuf
