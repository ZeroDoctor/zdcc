-- #test
local turtle = require("test.turtle_test_api")
-- #end

local log = require('../log.logs')

local script = {
	move = require("../lib.track_move"),
	dig = require("../lib.careful_dig"),
	place = require("../lib.ensure_place"),
	inventory = require("../lib.check_inventory"),

	init = function() end,
	update = function() return false end,
}

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
-- 	hard_retrace = true,
-- 	hard_reset = true,
-- 	move_limit = turtle.getFuelLevel() / 2,
-- 	enable_tags = false,
-- 	max_slots = 16,
-- 	really_ensure_place = false,
-- }```
function script:start(config)
	config = config or {}
	-- sane defaults
	config.avoid = config.avoid or {}
	config.patch = config.patch or {}
	config.put = config.put or {}
	config.refuel = config.refuel or true
	config.hard_retrace = config.hard_retrace or false
	config.hard_reset = config.hard_reset or false
	config.move_limit = turtle.getFuelLevel() / 2
	config.enable_tags = config.enable_tags or false
	config.max_slots = config.max_slots or 16
	config.really_ensure_place = config.really_ensure_place or false

	-- setup modules
	self.inventory.enable_tags = config.enable_tags
	self.inventory.max_slots = config.max_slots
	self.inventory:update()

	self.dig.avoid = config.avoid

	self.place.patch = config.patch or {}
	self.place.put = config.put or {}
	self.place.force_goback = config.really_ensure_place
	self.place:init(self.inventory, self.dig, self.move)

	-- TODO: place does not have inventory module

	self.move.hard_reset = config.hard_reset
	if config.refuel then
		self.move.limit = config.move_limit
	end

	if config.patch == nil and config.put == nil then
		self.move:init(self.dig, nil)
	else
		self.move:init(self.dig, self.place)
	end

	log:debug('[config={}]', config)

	-- setup loop
	script:init()

	self.move.limit = turtle.getFuelLevel() / 2

  local running = true
	while running do
		if config.refuel and self.move.should_goback then
			self.move:retrace(config.retrace_feel)
		end

		running = script:update() or false
	end
end

function script:front_dir() return 0 end
function script:right_dir() return 1 end
function script:back_dir() return 2 end
function script:left_dir() return 3 end
function script:top_dir() return 4 end
function script:bottom_dir() return 5 end

return script

