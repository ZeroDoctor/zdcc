-- #test
local textutils = require('test.textutils_test')
-- #end

local levels = {
	['TRACE'] = 0,
	['DEBUG'] = 1,
	['INFO'] = 2,
	['WARN'] = 3,
	['ERROR'] = 4,
	['FATAL'] = 5,
}

---@class logs
local module = {
	---@type file*|nil
	file = nil,
	log_path = 'out.log',
	level = 0
}

---@param level integer
---@param log_path string|nil
function module:init(level, log_path)
	print('[init] logs starting...')
	self.log_path = log_path or self.log_path
	self.file = io.open(self.log_path, "a")
	self.level = level or self.level
	if self.file ~= nil then
		self.file:write('----------------\n')
	else
		print('[error] failed to write to nil file')
	end
end

---@param self logs
---@param str string
---@param ... any
local function log(self, str, ...)
	local args = table.pack(...)

	for i = 1, args.n, 1 do
		local _start, _end = string.find(str, '{}')
		if _start ~= nil and _end ~= nil then
			local out = args[i]
			if not args[i] then
				out = 'nil'
			elseif type(args[i]) == 'table' then
				out = textutils.serialise(args[i])
			end
			str = str:sub(1, _start-1)..tostring(out)..str:sub(_end+1, #str)
		else
			str = str..' <extra:'..args[i]..'>'
		end
	end

	print(str)

	if self.file ~= nil then
		self.file:write(str..'\n')
		self.file:flush()
	else
		print('[error] failed to write to nil file')
	end
end

---@param str string 
---@param ... any
function module:trace(str, ...)
	if self.level > levels['TRACE'] then
		return
	end

	log(self, '[t:'..os.clock()..'] '
		..str,
		...
	)
end

---@param str string 
---@param ... any
function module:debug(str, ...)
	if self.level > levels['DEBUG'] then
		return
	end

	log(self, '[d:'..os.clock()..'] '
		..str,
		...
	)
end

---@param str string 
---@param ... any
function module:info(str, ...)
	if self.level > levels['INFO'] then
		return
	end

	log(self, '[i:'..os.clock()..'] '
		..str,
		...
	)
end

---@param str string 
---@param ... any
function module:warn(str, ...)
	if self.level > levels['WARN'] then
		return
	end

	log(self, '[w:'..os.clock()..'] '
		..str,
		...
	)
end

---@param str string 
---@param ... any
function module:error(str, ...)
	if self.level > levels['ERROR'] then
		return
	end

	log(self, '[e:'..os.clock()..'] '
		..str..'\n'
		..debug.traceback('tracing...', 2),
		...
	)
end

---@param str string 
---@param ... any
function module:fatal(str, ...)
	if self.level > levels['FATAL'] then
		return
	end

	log(self, '[f:'..os.clock()..'] '
		..str..'\n'
		..debug.traceback(),
		...
	)
	self:cleanup()
	os.exit(1)
end

function module:cleanup()
	if self.file == nil then
		print('[error] failed to close nil file')
		return
	end

	self.file:close()
end

return module
