-- #test
-- #end

local textutils = require('test.textutils_test')

local levels = {
	['DEBUG'] = 0,
	['INFO'] = 1,
	['WARN'] = 2,
	['ERROR'] = 3,
	['FATAL'] = 4,
}

local script = {
	file = nil,
	log_path = 'out.log',
	level = 0
}

function script:init(level, log_path)
	self.log_path = log_path or self.log_path
	self.file = io.open(self.log_path, "a")
	self.level = level or self.level
	if self.file ~= nil then
		self.file:write('----------------\n')
	else
		print('[error] failed to write to nil file')
	end
end

local function log(self, str, ...)
	local args = {...}

	for i = 1, #args, 1 do
		local _start, _end = string.find(str, '{}')
		if _start ~= nil and _end ~= nil then
			local out = args[i]
			if type(args[i]) == 'table' then
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

function script:debug(str, ...)
	if self.level > levels['DEBUG'] then
		return
	end

	log(self, '[d:'..os.clock()..'] '
		..str,
		...
	)
end

function script:info(str, ...)
	if self.level > levels['INFO'] then
		return
	end

	log(self, '[i:'..os.clock()..'] '
		..str,
		...
	)
end

function script:warn(str, ...)
	if self.level > levels['WARN'] then
		return
	end

	log(self, '[w:'..os.clock()..'] '
		..str,
		...
	)
end

function script:error(str, ...)
	if self.level > levels['ERROR'] then
		return
	end

	log(self, '[e:'..os.clock()..'] '
		..str..'\n'
		..debug.traceback(),
		...
	)
end

function script:fatal(str, ...)
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

function script:cleanup()
	if self.file == nil then
		print('[error] failed to close nil file')
		return
	end

	self.file:close()
end

return script

