-- #test
local turtle = require('test.turtle_test_api')
-- #end

local loop = require('lib.loop')
local shape = require('lib.make_shape')

-- local move = require('lib.track_move')
-- local dig = require('lib.careful_dig')
-- local place = require('lib.ensure_place')
-- local inventory = require('lib.check_inventory')

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
	obj = self.inventory:search_name('.*charcoal', true)
	if obj ~= nil then
		turtle.select(obj.location[1])
		turtle.refuel()
	end

	shape.place = false
	shape:init(self.move, self.place)
end

print("set width, length, and height from relative origin of turtle:")

print('enter width:')
local w = tonumber(io.read())
print('enter length:')
local l = tonumber(io.read())
print('enter height:')
local h = tonumber(io.read())

loop.update = function(self)
	shape:cuboid(w, l, h, "y")
	self.move:retrace(true)
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

