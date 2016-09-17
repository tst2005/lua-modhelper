
-- this helper should be use inside a `require` implementation to catch new module return values to build an uniq value to store in the package.loaded table.

local makemodfrom(callable, usual, meta)
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
	if callable type(callable)=="function" then
		mt.__call = callable
	end
	return setmetatable(M, mt)
end


-- # old module compatibility

-- makemodfrom(t1, nil, nil)	=> equals makemodfrom( nil, t1, t1)
-- makemodfrom(true, nil, nil)	=> empty table module

-- # new module support

-- makemodfrom(nil|<boolean>|<number>, nil, nil)	=> empty table module
-- makemodfrom(f1, nil, nil)	=> callable empty table module (#micro-module)
-- makemodfrom(f1, t1, nil)	=> callable table module (#mini-module)
-- makemodfrom(f1, t1, t2)	=> callable table module with custom meta (#mini-module)

-- makemodfrom(f1, t1, t1)	=> t1 should contains both usual and meta methods the meta __call will be f1

-- makemodfrom(t1, t1, t1)	=> the first argument is ignored

-- makemodfrom(f1, nil, t2)	=> like makemodfrom(f1, {}, t2) => callable table module with custom meta method (but no method)

