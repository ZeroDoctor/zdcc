
-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
-- remember to comment out above before use

local track = require("track_move")
local careful = require("careful_dig")
local ensure = require("ensure_place")
local check = require("check_inventory")

local script = {
	init = function(self, move, dig, put, inventory) end,
	update = function(self, move, dig, put, inventory)
		return false
	end,
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
-- 	config.move_limit = turtle.getFuelLevel() / 2,
-- 	config.enable_tags = false,
-- 	config.max_slots = 16,
-- }```
function script:start(config)
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

	-- setup modules
	check.enable_tags = check.enable_tags
	check.max_slots = config.max_slots

	careful.avoid = config.avoid

	ensure.patch = config.patch or {}
	ensure.put = config.put or {}
	ensure:init(check, careful)

	track.hard_reset = config.hard_reset
	if config.refuel then
		track.limit = config.move_limit
	end

	if config.patch == nil and config.put == nil then
		track:init(careful, nil)
	else
		track:init(careful, ensure)
	end

	-- setup loop
	script:init(track, careful, ensure, check)

  local running = true
	while running do
		running = script:update(track, careful, ensure, check)

		if config.refuel and track.should_goback then
			track:retrace(config.retrace_feel)
		end

	end
end

function script:front_dir() return 0 end
function script:right_dir() return 1 end
function script:back_dir() return 2 end
function script:left_dir() return 3 end
function script:top_dir() return 4 end
function script:bottom_dir() return 5 end

return script

