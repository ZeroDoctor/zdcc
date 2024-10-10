-- #test
local turtle = require('test.turtle_test_api')
-- #end

local log = require('../log.logs')
log:init(0)

local loop = require('../lib.loop')
local shape = require('../lib.make_shape')

-- local move = require('lib.track_move')
-- local dig = require('lib.careful_dig')
-- local place = require('lib.ensure_place')
-- local inventory = require('lib.check_inventory')

loop.init = function(self)
	self.move.auto_place_after = 7

	local fuel_regex = {'.*coal', '.*lava', '.*charcoal'}
	local obj = self.inventory:search_name(fuel_regex, true)
	if obj ~= nil then
		turtle.select(obj.location[1])
		turtle.refuel()
	end

	shape.place = false
	shape.force = 1
	shape:init(self.move, self.place)
end

log:info('set width, length, and height from relative origin of turtle:')

log:info('enter width:')
local w = tonumber(io.read())
log:info('enter length:')
local l = tonumber(io.read())
log:info('enter height:')
local h = tonumber(io.read())

log:debug('w={} l={} h={}', w, l, h)

loop.update = function(self)
	shape:cuboid(w, l, h, "y")
	self.move:retrace(1)
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
	hard_reset = 1,
}

loop:start(config)

log:cleanup()
