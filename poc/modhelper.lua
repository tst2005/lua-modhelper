
-- this helper should be use inside a `require` implementation to catch new module return values to build an uniq value to store in the package.loaded table.
-- or used at the end of a module
-- local M = {}
-- ... stuff ...
-- return require "modhelper"(M)

local function newmod(callable, usual, meta)
	if usual==nil and meta==nil and type(callable)=="table" then
		usual = callable
		meta = callable
		callable = nil
	end
	local M = {}
	if type(usual) == "table" then
		for k,v in pairs(usual) do
			if type(k)=="string" and not k:find("^__") then
				M[k]=v
			end
		end
	end
	local mt = {}
	if type(meta) == "table" then
		for k,v in pairs(meta) do
			if type(k)=="string" and k:find("^__") then
				mt[k] = v
			end
		end
	end
	-- overwrite the __call if callable is provided
	if callable and type(callable)=="function" then
		mt.__call = callable
	end
	return setmetatable(M, mt)
end


local function fshift(f)
	return function(_self, ...) return f(...) end
end
local M = {
	newmod = newmod,
	fshift = fshift,
}
return newmod(fshift(newmod), M, nil)



-- # old module compatibility

-- newmod(t1, nil, nil)	=> equals newmod( nil, t1, t1)
-- newmod(true, nil, nil)	=> empty table module

-- # new module support

-- newmod(nil|<boolean>|<number>, nil, nil)	=> empty table module
-- newmod(f1, nil, nil)	=> callable empty table module (#micro-module)
-- newmod(f1, t1, nil)	=> callable table module (#mini-module)
-- newmod(f1, t1, t2)	=> callable table module with custom meta (#mini-module)

-- newmod(f1, t1, t1)	=> t1 should contains both usual and meta methods the meta __call will be f1

-- newmod(t1, t1, t1)	=> the first argument is ignored

-- newmod(f1, nil, t2)	=> like newmod(f1, {}, t2) => callable table module with custom meta method (but no method)
