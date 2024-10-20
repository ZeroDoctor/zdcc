-- #test
local turtle = require("test.turtle_test_api")
-- #end

local log = require('../log.logs')

-- put/patch = {
-- 	{
-- 		name = "minecraft:oak_log",
-- 		tag = "torch",
-- 		where = ensure.left(),
-- 		location = 12,
-- 		force = false, -- if true then blocks can be replaced with new block
-- 	},
-- }

local module = {
	patch = {}, -- occurs when no blocks exists
	put = {}, -- occurs when blocks already exist
	check = require('../lib.check_inventory'),
	force_place = false, -- TODO: if true then place block if solid block not found

	pre_place = {},
	pre_placeUp = {},
	pre_placeDown = {}
}

function module:new(check)
	local class = setmetatable({}, self)
	self.__index = self

	self.check = check or self.check

	return class
end

function module:set_log(p_log) log = p_log end

function module:find_slot(config)
	local slot = config.slot
	local regex = true

	if config.name ~= nil then
		local o = self.check:search_name({config.name}, regex)
		if o ~= nil then
			slot = o.location[1]
		end
	elseif config.tag ~= nil then
		local o = self.check:search_tag(config.tag)
		if o ~= nil then
			slot = o.location[1]
		end
	end

	return slot
end

function module:turn_dir(config)
	if config.where == self:front() then
		self:place(config)
	elseif config.where == self:right() then
		turtle.turnRight()
		self:place(config)
		turtle.turnLeft()
	elseif config.where == self:back() then
		turtle.turnRight()
		turtle.turnRight()
		self:place(config)
		turtle.turnLeft()
		turtle.turnLeft()
	elseif config.where == self:left() then
		turtle.turnLeft()
		self:place(config)
		turtle.turnRight()
	elseif config.where == self:top() then
		self:placeUp(config)
	elseif config.where == self:bottom() then
		self:placeDown(config)
	end
end

function module:auto()
	for _, p in ipairs(self.patch) do
		module:turn_dir(p)
	end

	for _, p in ipairs(self.put) do
		module:turn_dir(p)
	end
end

function module:place(config, text)
	if config == nil then
		return turtle.place(text)
	end

	local prev_slot = turtle.getSelectedSlot()
	local slot = module:find_slot(config)
	if slot == nil then
		log:warn('{place:place} failed to find [name={}] object with [tag={}]',
			config.name, config.tag
		)
		return false
	end

	-- if not self.careful:dig() then
	-- 	log:warn('{place:place} failed to dig for [name={}]',
	-- 		config.name
	-- 	)
	-- end

	for index, _ in ipairs(self.pre_place) do
		if self.pre_place[index]() then
			return
		end
	end

	turtle.select(slot)
	turtle.place(text)
	turtle.select(prev_slot)
end

function module:placeUp(config, text)
	if config == nil then
		return turtle.placeUp(text)
	end

	local prev_slot = turtle.getSelectedSlot()
	local slot = module:find_slot(config)
	if slot == nil then
		log:warn('{place:placeUp} failed to find [name={}] object with [tag={}] or [slot={}]',
			config.name, config.tag, config.slot
		)
		return false
	end

	-- if not self.careful:digUp() then
	-- 	log:warn('{place:placeUp} failed to dig up for [name={}]',
	-- 		config.name
	-- 	)
	-- end

	for index, _ in ipairs(self.pre_placeUp) do
		if self.pre_placeUp[index]() then
			return
		end
	end

	turtle.select(slot)
	turtle.placeUp(text)
	turtle.select(prev_slot)
end

function module:placeDown(config, text)
	if config == nil then
		return turtle.placeDown(text)
	end

	local prev_slot = turtle.getSelectedSlot()
	local slot = self:find_slot(config)
	if slot == nil then
		log:warn('{place:placeDown} failed to find [name={}] object with [tag={}] or [slot={}]',
			config.name, config.tag, config.slot
		)
		return false
	end

	-- if not self.careful:digDown() then
	-- 	log:warn('{place:placeDown} failed to dig down for [name={}]',
	-- 		config.name
	-- 	)
	-- end

	for index, _ in ipairs(self.pre_placeDown) do
		if self.pre_placeDown[index]() then
			return
		end
	end

	turtle.select(slot)
	turtle.placeDown(text)
	turtle.select(prev_slot)
end

function module:front() return 0 end
function module:right() return 1 end
function module:back() return 2 end
function module:left() return 3 end
function module:top() return 4 end
function module:bottom() return 5 end

return module

