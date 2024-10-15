-- #test
local turtle = require('test.turtle_test_api')
-- #end

local log = require('../log.logs')
log:init(1)

local loop = require('../lib.loop'):new()
loop:set_log(log)
local shape = require('../lib.make_shape')
shape = shape:new(loop.track, loop.ensure)

-- local move = require('lib.track_move')
-- local dig = require('lib.careful_dig')
-- local place = require('lib.ensure_place')
-- local inventory = require('lib.check_inventory')

loop.init = function(self)
	self.track.auto_place_after = 12

	local fuel_regex = {'.*coal', '.*lava', '.*charcoal'}
	local obj = self.check:search_name(fuel_regex, true)
	if obj ~= nil then
		turtle.select(obj.location[1])
		turtle.refuel()
	end

	shape.will_place = false
	shape.force = 1
	shape:init(self.track, self.ensure)
end

print('set width, length, and height from relative origin of turtle:')

print('enter width:')
local w = tonumber(io.read())
print('enter length:')
local l = tonumber(io.read())
print('enter height:')
local h = tonumber(io.read())

log:debug('{mining} w={} l={} h={}', w, l, h)

loop.update = function(self)
	shape:cuboid(w, l, h, "y")
	self.track:retrace(1)
	return false
end

local config = {
	avoid = { "minecraft:chest" },
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
