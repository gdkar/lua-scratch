#! /usr/bin/env luajit

local test = setmetatable({ a = 'a'},{
    __newindex = function(self,key,val)
        print(rawget(self,key),key,val)
    end})

test.a = 'b'
test.a = nil
test.a = 'c'
