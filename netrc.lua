--[[

Copyright (C) 2013 Conjur Inc

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]
-- package.path = package.path .. ';/Users/jon/Work/conjur-nginx-lua/lib/?.lua'
-- inspect = require('inspect')

local function netrc_parse(lines)
    machine = nil
    local tokens = {}
    for _, line in ipairs(lines) do
        line = line:gsub('#.*$', '') 
        for p in line:gmatch('%S+') do tokens[#tokens + 1] = p end
    end
    
    local mtokens = {}
    local mt = nil
    for _, token in ipairs(tokens) do
        if token == 'machine' then
            mt = {}
            mtokens[#mtokens+1] = mt
        else
            mt[#mt+1] = token
        end
    end
    local machines = {}
    for _, mt in ipairs(mtokens) do
        local key = mt[1]
        machines[key] = {}
        local mac = machines[key]
        mac.host = key
        table.remove(mt, 1)
        key = nil
        for _, tok in ipairs(mt) do
            if not key then key = tok 
            else
                mac[key] = tok
                key = nil
            end   
        end
    end
    return machines
end

local function netrc_new(path)
    if not path then path = os.getenv("HOME") .. "/.netrc" end
    local fd = io.open(path, 'r')
    if not fd then error("no netrc file found at " .. path) end
    local lines = {}
    for line in fd:lines() do lines[#lines + 1] = line end
    fd:close()
    -- print(lines, inspect(lines))
    return netrc_parse(lines)
end
local netrc_meta = {}
local netrc_module_meta = {}

function netrc_module_meta:__index(key)
    if self.default == 0 then 
        self.default = netrc() 
    end
    return self.default[key]
end

function netrc_module_meta:__call(...)
    return setmetatable(netrc_new(...), netrc_meta)
end

function netrc_meta:index(self, key) return self.machines[key] end

netrc = setmetatable({default = 0}, netrc_module_meta)
function netrc:hosts()
    if self.default == 0 then self.default = netrc() end
    return pairs(self.default)
end

return netrc