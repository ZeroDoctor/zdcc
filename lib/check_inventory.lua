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

local module = {
	inventory = {},
	map = {},
	max_slots = 16,
	enable_details = false,
}

function module:new()
	local class = setmetatable({}, self)
	self.__index = self
	return class
end

function module:set_log(p_log) log = p_log end

-- TODO: maybe add 'remove()' and 'add()' methods
-- to reduce update() usage

local function find_items(map, list)
	local found = {}
	for k in pairs(map) do
		for _, name in ipairs(list) do
			local r = string.find(k, name)
			if r ~= nil then
				table.insert(found, k)
			end
		end
	end

	return found
end

function module:search_tag(tag)
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

function module:search_name(list, regex)
	regex = regex or false

	if regex then
		list = find_items(self.map, list) or list
	end

	for _, name in ipairs(list) do
		log:trace('{inventory:search_name} searching [map={}] with [name={}]', self.map, name)

		if self.map[name] == nil or
			self.map[name].location == nil or
			#self.map[name].location == 0 then
			log:debug('{inventory:search_name} not found [name={}]', name)
			return
		end

		local found = self.inventory[self.map[name].location[1]]
		log:debug('{inventory:search_name} found {}', found)
		return found
	end
end

function module:update()
	local count = {}
	self.inventory = {}

	for i = 1, self.max_slots, 1 do
		local item = turtle.getItemDetail(i, self.enable_details)
		if item ~= nil then
			item.location = {i}
			self.inventory[i] = item
			count[item.name] = (count[item.name] or 0) + 1
			if self.map[item.name] ~= nil and #self.map[item.name].location < count[item.name] then -- found a previous item with same name
				local prev = tbl.copy(self.map[item.name])
				prev.count = prev.count + self.inventory[i].count
				table.insert(prev.location, self.inventory[i].location[1])
				self.map[item.name] = prev
			else
				self.map[item.name] = item
			end
		end
	end
end

function module:flatten()
	module:update()

	for _, t in pairs(self.map) do -- iterate through slots
		 if #t.location > 1 then -- only flatten if more than one location found
		 	module:_flatten(t)
		 end
	end

	module:update()
end

function module:_flatten(t)
	local free = {}

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
end

return module

