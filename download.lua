
local base_dir = 'https://raw.githubusercontent.com/ZeroDoctor/zdcc/main'

local files = {
	'/carefule_dig.lua',
	'/check_inventory.lua',
	'/ensure_place.lua',
	'/loop.lua',
	'/make_shape.lua',
	'/mining.lua',
	'/test.lua',
	'/track_move.lua',
	'/test/dig_test.lua',
	'/test/loop_test.lua',
	'/test/move_test.lua',
	'/test/place_test.lua',
	'/test/tbl.lua',
	'/test/turtle_test_api.lua',
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

local function main()
	for _, file in ipairs(files) do
		download_file(file)
	end
end

main()

