-- #test
local turtle = require("test.turtle_test_api")
-- #end

local log = require('log.logs')

-- put/patch = {
-- 	{
-- 		name = "minecraft:oak_log",
-- 		tag = "torch",
-- 		where = ensure.left(),
-- 		location = 12,
-- 		force = false, -- if true then blocks can be replaced with new block
-- 	},
-- }

local script = {
	patch = {}, -- occurs when no blocks exists
	put = {}, -- occurs when blocks already exist
	check = require('lib.check_inventory'),
	careful =  require('lib.careful_dig'),
	force_place = false, -- TODO: if true then place block if solid block not found
	force_goback = false,
}

local function find_slot(config, sc)
	local slot = config.slot

	if config.name ~= nil then
		local o = sc.check:search_name(config.name)
		if o ~= nil then
			slot = o.location[1]
		end
	elseif config.tag ~= nil then
		local o = sc.check:search_tag(config.tag)
		if o ~= nil then
			slot = o.location[1]
		end
	end

	return slot
end

local function turn_dir(solid, config, sc)
	if config.where == sc:front() then
		if solid and not turtle.detect() then
			return
		end

		sc:place(config)
	elseif config.where == sc:right() then
		turtle.turnRight()
		if solid and not turtle.detect() then
			turtle.turnLeft()
			return
		end

		sc:place(config)
		turtle.turnLeft()
	elseif config.where == sc:back() then
		turtle.turnRight()
		turtle.turnRight()
		if solid and not turtle.detect() then
			turtle.turnLeft()
			turtle.turnLeft()
			return
		end

		sc:place(config)
		turtle.turnLeft()
		turtle.turnLeft()
	elseif config.where == sc:left() then
		turtle.turnLeft()
		if solid and not turtle.detect() then
			turtle.turnRight()
			return
		end

		sc:place(config)
		turtle.turnRight()
	elseif config.where == sc:top() then
		if solid and not turtle.detectUp() then
			return
		end

		sc:placeUp(config)
	elseif config.where == sc:bottom() then
		if solid and not turtle.detectDown() then
			return
		end

		sc:placeDown(config)
	end
end

function script:init(check, careful, track)
	self.check = check or self.check
	self.careful = careful or self.careful
	self.track = track or self.track
end

function script:auto()
	for _, p in ipairs(self.patch) do
		turn_dir(false, p, self)
	end

	for _, p in ipairs(self.put) do
		turn_dir(true, p, self)
	end
end

function script:place(config, text)
	if config == nil then
		return turtle.place(text)
	end

	local prev_slot = turtle.getSelectedSlot()
	local slot = find_slot(config, self)
	if slot == nil then
		log:error('failed to find [name={}] object with [tag={}] or [slot={}]',
			config.name, config.tag, config.slot
		)
		return false
	end

	turtle.select(slot)
	turtle.place(text)
	turtle.select(prev_slot)
end

function script:placeUp(config, text)
	if config == nil then
		return turtle.placeUp(text)
	end

	local prev_slot = turtle.getSelectedSlot()
	local slot = find_slot(config, self)
	if slot == nil then
		log:error('failed to find [name={}] object with [tag={}] or [slot={}]',
			config.name, config.tag, config.slot
		)
		return false
	end

	turtle.select(slot)
	turtle.placeUp(text)
	turtle.select(prev_slot)
end

function script:placeDown(config, text)
	if config == nil then
		return turtle.placeDown(text)
	end

	local prev_slot = turtle.getSelectedSlot()
	local slot = find_slot(config, self)
	if slot == nil then
		log:error('failed to find [name={}] object with [tag={}] or [slot={}]',
			config.name, config.tag, config.slot
		)
		return false
	end

	turtle.select(slot)
	turtle.placeDown(text)
	turtle.select(prev_slot)
end

function script:front() return 0 end
function script:right() return 1 end
function script:back() return 2 end
function script:left() return 3 end
function script:top() return 4 end
function script:bottom() return 5 end

return script

