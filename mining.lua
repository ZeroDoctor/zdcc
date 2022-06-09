-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
local tbl = require("test.tbl")
-- remember to comment out above before use

local loop = require("loop")

-- move = require("track_move"),
-- dig = require("careful_dig"),
-- place = require("ensure_place"),
-- inventory = require("check_inventory"),

print("set x, y, and z from relative origin of turtle")
io.write("how many points to expect? ")
local max_number_points = io.read("n")

local vectors = {}
for _=1, max_number_points, 1 do
	io.write("enter x, y, and z sperated by spaces ")

	table.insert(vectors, {
		x = io.read("n"),
		y = io.read("n"),
		z = io.read("n")
	})
end

print(tbl.print_table(vectors))

loop.init = function(self)
	self.move.auto_place_after = 7

	local obj = self.inventory:search_tag('fuel')
	if obj ~= nil then
		turtle.select(obj.location)
		turtle.refuel()
	end
end

loop.update = function(self)
	self.move:forward(10)
	print(tbl.print_table(self.move))

	return true
end

local config = {
	avoid = {"minecraft:chest"},
	patch = {
		{
			name = "minecraft:cobble_stone",
			where = loop:bottom_dir(),
			location = 1,
		},
	},
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

