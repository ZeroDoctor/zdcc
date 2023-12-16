
local urls = {
	['*'] = {
		readAll = function()
			return ''
		end,
	},
}

local function get(path, header)
	local file = io.open('mining.lua', 'r')
	if file == nil then
		return ''
	end

	local content = file:read('a')
	file:close()

	urls['*'].readAll = function()
		return content
	end

	return urls['*']
end

return {
	get = get
}
