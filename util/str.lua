local function slice(str, first, last)
	local sliced = ''
	local first = first or 1
	local last = last or #str

	for i = first, last, 1 do
		sliced = sliced..str:sub(i,i)
	end

	return sliced
end

local function slice_tbl(tbl, first, last, step)
	local sliced = {}
	local first = first or 1
	local last = last or #tbl
	local step = step or 1

	for i = first, last, step do
		sliced[#sliced+1] = tbl[i]
	end

	return sliced
end

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

local function trim(str)
	if type(str) ~= 'string' then
		return str
	end

	return str:gsub('%s+', '')
end

local function find_replace_word(lines, find, replace)
	local result = {}

	for k, v in pairs(lines) do
		local start_index, end_index = string.find(v, find)
		if start_index then
			print('found ['..k..'] '..v)
			local a = slice(v, 1, start_index-1)
			local b = slice(v, end_index+1, #v)
			v = a..replace..b
			print('\treplace '..v)
		end

		result[k] = v
	end

	return result
end

return {
	find_replace_word = find_replace_word,
	slice = slice,
	split = split,
	trim = trim,
	slice_tbl = slice_tbl,
}
