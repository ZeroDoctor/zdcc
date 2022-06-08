-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
-- remember to comment out above before use


local loop = require("loop")
local tbl = require("test.tbl")

-- move = require("track_move"),
-- dig = require("careful_dig"),
-- place = require("ensure_place"),
-- inventory = require("check_inventory"),

loop.init = function(self)
	self.move.auto_place_after = 7

	local obj = self.inventory:search_tag('fuel')
	if obj ~= nil then
		turtle.select(obj.location)
		turtle.refuel()
	end
end

loop.update = function(self)
	self.move:forward()
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

