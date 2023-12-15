local util = require('util.str')

local function comment_out_test(content)
	local lines = util.split(content, '\n')
	content = ''

	local ignore = true
	for i in ipairs(lines) do
		local istart, _ = string.find(lines[i], "-- #test")
		local iend, _ = string.find(lines[i], "-- #end")
		if istart then
			ignore = false
			goto continue
		end

		if iend then
			ignore = true
		end

		if not ignore then
			istart, _ = string.find(lines[i], "--")
			if istart then
				lines[i] = "-- "..lines[i]
			end
		end
		:: continue ::
		content = content..lines[i]..'\n'
	end

	return content
end

local function update_test()
	local path = 'lib/loop.lua'
	local file = io.open(path, "r")
	if file == nil then
		print('failed to read file '..path)
		return
	end

	local content = file:read("*a")
	file:close()

	content = comment_out_test(content)
	print(content)
end

update_test()
