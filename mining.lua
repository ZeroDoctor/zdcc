-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
local tbl = require("test.tbl")
-- remember to comment out above before use

local loop = require("loop")
local shape = require('make_shape')

-- move = require("track_move"),
-- dig = require("careful_dig"),
-- place = require("ensure_place"),
-- inventory = require("check_inventory"),

loop.init = function(self)
	self.move.auto_place_after = 7

	local obj = self.inventory:search_name('.*coal', true)
	if obj ~= nil then
		turtle.select(obj.location[1])
		turtle.refuel()
	end
	obj = self.inventory:search_name('.*lava', true)
	if obj ~= nil then
		turtle.select(obj.location[1])
		turtle.refuel()
	end

	shape.place = false
	shape:init(self.move, self.place)
end

print("set width, length, and heigth from relative origin of turtle:")

local w = io.read("n")
local l = io.read("n")
local h = io.read("n")

loop.update = function(self)
	shape:cuboid(w, l, h, "y")

	print(tbl.print_table(self.move))

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

