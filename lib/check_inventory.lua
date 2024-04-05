-- #test
local turtle = require("test.turtle_test_api")
-- #end

local log = require('../log.logs')
local tbl = require('../util.tbl')

-- inventory = {
-- 	{
-- 		name = "minecraft:oak_log",
-- 		tags = {["minecraft:logs"] = true},
-- 		count = 32,
-- 		location = 1,
-- 	},
-- }
--
-- map = {
--  ["minecraft:oak_log"] = {
-- 		location = { 1 },
-- 		count = 11,
-- 	},
-- }

local script = {
	inventory = {},
	map = {},
	max_slots = 16,
	enable_tags = false,
}

-- TODO: maybe add 'remove()' and 'add()' methods
-- to reduce update() usage

local function find_item(map, name)
	for k in pairs(map) do
			local r = string.find(k, name)
			if r ~= nil then
				return k
			end
		end
end

function script:search_tag(tag)
	for _, inv in pairs(self.inventory) do
		if inv.tags == nil then
			return
		end

		for k in pairs(inv.tags) do
			local r = string.find(k, tag)
			if r ~= nil then
				log:debug('{inventory:search_tag} found {}', inv)
				return inv
			end
		end
	end
end

function script:search_name(name, regex)
	regex = regex or false

	if regex then
		name = find_item(self.map, name) or name
	end

	if self.map[name] == nil or
		self.map[name].location == nil or
		#self.map[name].location == 0 then
		return
	end

	local found = self.inventory[self.map[name].location[1]]
	log:debug('{inventory:search_name} found {}', found)
	return found
end

function script:update()
	local count = {}

	for i = 1, self.max_slots, 1 do
		local t = turtle.getItemDetail(i, self.enable_tags)
		if t ~= nil then
			t.location = {i}
			self.inventory[i] = t
			count[t.name] = (count[t.name] or 0) + 1
			if self.map[t.name] ~= nil and #self.map[t.name].location < count[t.name] then -- found a previous item with same name
				local prev = tbl.copy(self.map[t.name])
				prev.count = prev.count + self.inventory[i].count
				table.insert(prev.location, self.inventory[i].location[1])
				self.map[t.name] = prev
			else
				self.map[t.name] = t
			end
		end
	end
end

function script:flatten()
	script:update()

	for _, t in pairs(self.map) do -- iterate through slots
		 if #t.location > 1 then -- only flatten if more than one location found
		 	script:_flatten(t)
		 end
	end

	script:update()
end

function script:_flatten(t)
	local free = {}

	log:debug('start [map={}]', t)
	for _, loc in ipairs(t.location) do -- iterate through all same blocks location
		local count = turtle.getItemCount(loc)
		if count < 64 and #free > 0 then
			for i, f in ipairs(free) do -- check available free locations
				turtle.select(f.location)
				if not turtle.transferTo(loc, f.count) then
					free[i].count = turtle.getItemCount(f.location)
					return
				else
					count = count + f.count
				end
				turtle.select(loc)
			end

			table.insert(free, {location=loc, count=count})
		elseif count < 64 then
			table.insert(free, {location=loc, count=count})
		end
	end
	log:debug('end [map={}]', free)
end

return script

