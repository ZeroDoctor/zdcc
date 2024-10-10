-- #test
local turtle = require('test.turtle_test_api')
-- #end

local log = require('../log.logs')
log:init(0)

local loop = require('../lib.loop')
local shape = require('../lib.make_shape')

loop.init = function(self)
	local fuel_regex = {'.*coal', '.*lava', '.*charcoal'}
	local obj = self.inventory:search_name(fuel_regex, true)
	if obj ~= nil then
		turtle.select(obj.location[1])
		turtle.refuel()
	end

	shape.place = true
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
	shape:cuboid(w, l, h, "n")
	self.move:retrace(false)
	return false
end

local config = {
	avoid = {"minecraft:chest"},
	refuel = true,
	hard_reset = 0,
}

loop:start(config)

log:cleanup()

