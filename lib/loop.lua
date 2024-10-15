-- #test
local turtle = require("test.turtle_test_api")
-- #end

local log = require('../log.logs')

local module = {
	move = require("../lib.track_move"),
	dig = require("../lib.careful_dig"),
	place = require("../lib.ensure_place"),
	inventory = require("../lib.check_inventory"),

	init = function() end,
	update = function() return false end,
}

function module:new(move, dig, place, inventory)
	local class = setmetatable({}, self)
	self.__index = self

	self.inventory = inventory or self.inventory:new()
	self.dig = dig or self.dig:new()
	self.place = place or self.place:new(inventory, dig)
	self.move = move or self.move:new(dig, place, inventory)

	return class
end

function module:set_log(p_log) log = p_log end

-- start initialize modules, prepares loop
-- and starts "game" loop which is the heart of
-- the turtle.
-- 	```lua
-- params: config = {
-- 	avoid = {"minecraft:logs", ...}, -- ipairs of tags
-- 	patch = {{
-- 		name = "minecraft:oak_log",
-- 		tag = "torch",
-- 		where = loop.left_dir(),
-- 		location = 12,
-- 		force = false, -- if true then blocks can be replaced with new block
-- 	}, ...}, -- pairs
-- 	put = {...}, -- same as patch
-- 	refuel = true,
-- 	hard_reset = 1,
-- 	move_limit = turtle.getFuelLevel() / 2,
-- 	enable_details = false,
-- 	max_slots = 16, -- number to slots to check and keep track in check_inventory
-- }```
function module:start(config)
	config = config or {}
	-- sane defaults
	config.avoid = config.avoid or {}
	config.patch = config.patch or {}
	config.put = config.put or {}
	config.refuel = config.refuel or true
	config.hard_reset = config.hard_reset or 0
	config.move_limit = turtle.getFuelLevel() / 2
	config.enable_details = config.enable_details or false
	config.max_slots = config.max_slots or 16

	-- setup modules
	self.inventory = self.inventory or self.inventory:new()
	self.inventory:set_log(log)
	self.inventory.enable_details = config.enable_details
	self.inventory.max_slots = config.max_slots
	self.inventory:update()

	self.dig = self.dig or self.dig:new()
	self.dig:set_log(log)
	self.dig.avoid = config.avoid

	self.place = self.place or self.place:new(self.inventory, self.dig)
	self.place:set_log(log)
	self.place.patch = config.patch or {}
	self.place.put = config.put or {}

	-- TODO: place does not have inventory module

	self.move.hard_reset = config.hard_reset
	if config.refuel then
		self.move.limit = config.move_limit
	end

	if config.patch == nil and config.put == nil then
		self.move = self.move or self.move:new(self.dig, nil)
	else
		self.move = self.move or self.move:new(self.dig, self.place)
	end
	self.move:set_log(log)

	log:debug('{loop:start} [config={}]', config)

	self.move.limit = turtle.getFuelLevel() / 2

  local running = true
	while running do
		if config.refuel then
			self.move:retrace(config.hard_reset)
		end

		running = module:update() or false
	end
end

function module:front_dir() return 0 end
function module:right_dir() return 1 end
function module:back_dir() return 2 end
function module:left_dir() return 3 end
function module:top_dir() return 4 end
function module:bottom_dir() return 5 end

return module

