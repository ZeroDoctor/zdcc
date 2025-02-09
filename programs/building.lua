-- #test
local turtle = require('test.turtle_test_api')
-- #end

local log = require('../log.logs')
log:init(1)

local loop = require('../lib.loop'):new()
loop:set_log(log)
local shape = require('../lib.make_shape')
shape = shape:new(loop.track, loop.ensure, {})

loop.init = function(self)
	local fuel_regex = {'.*coal', '.*lava', '.*charcoal'}
	local obj = self.check:search_name(fuel_regex, true)
	if obj ~= nil then
		turtle.select(obj.location[1])
		turtle.refuel()
	end

	shape.will_place = true
	shape.block = {
		name = ".*minecraft.*",
	}
	shape:init(self.track, self.ensure)
end

print('set width, length, and height relative to turtle\'s origin:')

print('enter width:')
local w = tonumber(io.read())
print('enter length:')
local l = tonumber(io.read())
print('enter height:')
local h = tonumber(io.read())

log:debug('{building} w={} l={} h={}', w, l, h)

loop.update = function(self)
	shape:cuboid(w, l, h, "n")
	self.track:retrace(false)
	return false
end

local config = {
	avoid = { "minecraft:chest" },
	refuel = true,
	hard_reset = 0,
}

loop:start(config)

log:cleanup()

