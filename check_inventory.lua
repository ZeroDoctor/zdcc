
-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
-- remember to comment out above before use

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

function script:init(config)
	self.enable_tags = config.enable_tags or false
	self.max_slots = config.max_slots or 16
end

function script:search_tag(tag)
	for _, inv in ipairs(self.inventory) do
		for k in pairs(inv.tags) do
			local r = string.find(k, tag)
			if r ~= nil then
				return inv
			end
		end
	end
end

function script:search_name(name)
	if self.map[name].location == nil or #self.map[name].location == 0 then
		return nil
	end

	return self.inventory[self.map[name].location[1]]
end

function script:update()
	for i = 1, self.max_slots, 1 do
		local t = turtle.getItemDetail(i, self.enable_tags)
		if t ~= nil then
			self.inventory[i] = t
			self.inventory[i].location = i
			if self.map[t.name] ~= nil then -- found a previous item with same name
				local prev = self.map[t.name]
				table.insert(prev.location, i)
				prev.count = prev.count + t.count
				self.map[t.name] = prev
			else
				self.map[t.name] = t
				table.insert(self.map[t.name].location, i)
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

return script
