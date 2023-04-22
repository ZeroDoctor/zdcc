
local base_dir = 'https://raw.githubusercontent.com/ZeroDoctor/zdcc/main'

local files = {
	'/lib/careful_dig.lua',
	'/lib/check_inventory.lua',
	'/lib/ensure_place.lua',
	'/lib/loop.lua',
	'/lib/make_shape.lua',
	'/lib/track_move.lua',
	'/test/dig_test.lua',
	'/test/loop_test.lua',
	'/test/move_test.lua',
	'/test/place_test.lua',
	'/test/tbl.lua',
	'/test/turtle_test_api.lua',
	'/mining.lua',
	'/test.lua',
}


local function download_file(path)
	print('downloading '..path..'...')
	local request = http.get(base_dir..path)

	local file = io.open(path, 'w')
	if file ~= nil then
		file:write(request.readAll())
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

