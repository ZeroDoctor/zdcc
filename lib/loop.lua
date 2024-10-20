-- #test
local turtle = require("test.turtle_test_api")
-- #end

local log = require('../log.logs')

local module = {
	track = require("../lib.track_move"),
	careful = require("../lib.careful_dig"),
	ensure = require("../lib.ensure_place"),
	check = require("../lib.check_inventory"),

	init = function() end,
	update = function() return false end,
}

function module:new(move, dig, place, inventory)
	local class = setmetatable({}, self)
	self.__index = self

	self.check = inventory or self.check:new()
	self.careful = dig or self.careful:new()
	self.ensure = place or self.ensure:new(inventory)
	self.track = move or self.track:new()

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
	self.check = self.check or self.check:new()
	self.check:set_log(log)
	self.check.enable_details = config.enable_details
	self.check.max_slots = config.max_slots
	self.check:update()

	self.careful = self.careful or self.careful:new()
	self.careful:set_log(log)
	self.careful.avoid = config.avoid

	self.ensure = self.ensure or self.ensure:new(self.check)
	self.ensure:set_log(log)
	self.ensure.patch = config.patch or {}
	self.ensure.put = config.put or {}

	-- TODO: place does not have inventory module

	self.track.hard_reset = config.hard_reset
	if config.refuel then
		self.track.limit = config.move_limit
	end

	self.track = self.track or self.track:new()
	self.track:set_log(log)

	log:debug('{loop:start} [config={}]', config)

	self.track.limit = turtle.getFuelLevel() / 2

	self.init()

	local running = true
	while running do
		if config.refuel then
			self.track:retrace(config.hard_reset)
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
