-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
-- remember to comment out above before use

local loop = require("loop")
local shape = require('make_shape')

-- move = require("track_move"),
-- dig = require("careful_dig"),
-- place = require("ensure_place"),
-- inventory = require("check_inventory"),

print("set width, length, and heigth from relative origin of turtle:")

local w = io.read("n")
local l = io.read("n")
local h = io.read("n")

loop.init = function(self)
	self.move.auto_place_after = 7

	local obj = self.inventory:search_name('.*coal')
	if obj ~= nil then
		turtle.select(obj.location[1])
		turtle.refuel()
	end
	obj = self.inventory:search_name('.*lava')
	if obj ~= nil then
		turtle.select(obj.location[1])
		turtle.refuel()
	end

	shape.place = false
	shape:init(self.move, self.place)
end

loop.update = function(self)
	shape:cuboid(w, l, h)

	return false
end

local config = {
	avoid = {"minecraft:chest"},
	put = {
		{
			name = "minecraft:torch",
			where = loop:left_dir(),
			location = 16,
		},
	},
	refuel = true,
	hard_retrace = true,
}

loop:start(config)

