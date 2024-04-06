-- #test
local http = require('test.http_test')
local os = require('test.os_test')
-- #end

local base_dir = 'https://raw.githubusercontent.com/ZeroDoctor/zdcc/main'

local files = {
	'/client/client.lua',
	'/lib/careful_dig.lua',
	'/lib/check_inventory.lua',
	'/lib/ensure_place.lua',
	'/lib/loop.lua',
	'/lib/make_shape.lua',
	'/lib/map_inspect.lua',
	'/lib/track_move.lua',
	'/log/logs.lua',
	'/programs/mining.lua',
	'/programs/building.lua',
	'/server/server.lua',
	'/update.lua'
}

local function split(str, split_on)
	if split_on == nil then
		split_on = '%s'
	end

	local result = {}
	for s in string.gmatch(str, '([^'..split_on..']+)') do
		table.insert(result, s)
	end

	return result
end

local function comment_out_test(content)
	local lines = split(content, '\n')
	content = ''

	local ignore = true
	for i in ipairs(lines) do
		local istart, _ = string.find(lines[i], "-- #test")
		local iend, _ = string.find(lines[i], "-- #end")

		if iend then
			ignore = true
		end

		if not ignore then
			istart, _ = string.find(lines[i], "--")
			if istart then
				lines[i] = "-- "..lines[i]
			end
		end

		if istart then
			ignore = false
		end
		content = content..lines[i]..'\n'
	end

	return content
end

local function download_file(path)
	print('downloading '..path..'...')
	local request = http.get(
		base_dir..path,
    {
        ['Cache-Control'] = 'no-cache, no-store',
        ['Pragma'] = 'no-cache'
    }
	)
	if request == nil then
		print('[ERROR] failed to download: '..path)
		return
	end

	local file = io.open(path, 'w')
	if file ~= nil then
		file:write(comment_out_test(request.readAll()))
		file:close()
	end

	request.close()
end

local function update()
	download_file('/update.lua')
end

local function main()
	if arg ~= nil and #arg > 0 and arg[1] == '--update'then
		update()
		os.run({}, "./update.lua")
		return
	end

	for _, file in ipairs(files) do
		download_file(file)
	end

end

main()

