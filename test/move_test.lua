
local textutils = require("test.textutils_test")
local log = require('../log.logs')

local function init(l)
	log = l or log
end

local function movement_test()
	local track = require('../lib.track_move')
	track = track:new()
	track:set_log(log)

	track:forward(5) track:turn_left(3)
	track:forward(4) track:turn_left(2)
	track:forward(7) track:turn_left(5)
	track:forward(1)
	track:back(3)
	track:forward(1)
	track:up(4)      track:turn_right(1)
	track:forward(9) track:turn_right(1)
	track:back(3)
	track:forward(2)
	track:down(3)

	local want = {
		x = 5,
		y = 1,
		z = -12,
		dir = 0
	}

	if want.x ~= track.location.x then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.x), tostring(track.location.x))
	end
	if want.y ~= track.location.y then
		log:error('with y\n\t want {} \n\t got {}', tostring(want.y), tostring(track.location.y))
	end
	if want.z ~= track.location.z then
		log:error('with z\n\t want {} \n\t got {}', tostring(want.z), tostring(track.location.z))
	end
	if want.dir ~= track.location.dir then
		log:error('with dir\n\t want {} \n\t got {}', tostring(want.dir), tostring(track.location.dir))
	end

	-- print(test.print_table(script))
end

local function retrace_test()
	log:info('testing soft retace test...')
	local track = require('../lib.track_move')
	track = track:new()
	track:set_log(log)

	track:forward(5) track:turn_left(3)
	track:forward(4) track:turn_left(2)
	track:forward(8) track:turn_left(5)
	track:forward(8) track:turn_left(5)
	track:forward(1)
	track:back(3)
	track:forward(1)
	track:up(4)      track:turn_right(1)
	track:up(4)      track:turn_right(1)
	track:forward(9) track:turn_right(7)
	track:back(3)
	track:forward(2)
	track:down(4)
	track:forward(9) track:turn_right(2)
	track:forward(7) track:turn_right(1)

	track:retrace(0)

	-- print(textutils.serialise(script))
	-- print(script.x, script.y, script.z, script.dir)

	local want = {
		x = 0,
		y = 0,
		z = 0,
		dir = 0
	}

	if want.x ~= track.location.x then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.x), tostring(track.location.x))
	end
	if want.y ~= track.location.y then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.y), tostring(track.location.y))
	end
	if want.z ~= track.location.z then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.z), tostring(track.location.z))
	end
	if want.dir ~= track.location.dir then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.dir), tostring(track.location.dir))
	end

	log:info('testing hard retace test...')

	track:forward(5) -- 5 0 0
	track:turn_left(3) track:forward(4) -- 5 0 4
	track:turn_left(2) track:forward(8) -- 5 0 -4
	track:turn_left(5) track:forward(2) -- 3 0 -4
	track:turn_left(1) track:forward(3) -- 3 0 -1
	track:turn_left(6) track:forward(1) -- 3 0 -2
	track:back(3) -- 3 0 1 
	track:forward(1) -- 3 0 0
	track:up(4) -- 3 4 0
	track:turn_right(1) track:up(4) -- 3 8 0
	track:turn_right(1) track:forward(9) -- 3 8 9
	track:turn_right(7) track:forward(2) -- 5 8 9
	track:down(4) -- 1 4 9
	track:turn_right(1) track:forward(7) -- 5 4 16
	track:back(3) -- 5 4 13

	track:retrace(1)

	if want.x ~= track.location.x then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.x), tostring(track.location.x))
	end
	if want.y ~= track.location.y then
		log:error('with y\n\t want {} \n\t got {}', tostring(want.y), tostring(track.location.y))
	end
	if want.z ~= track.location.z then
		log:error('with z\n\t want {} \n\t got {}', tostring(want.z), tostring(track.location.z))
	end
	if want.dir ~= track.location.dir then
		log:error('with dir\n\t want {} \n\t got {}', tostring(want.dir), tostring(track.location.dir))
	end
end

local function to_test()
	local track = require('../lib.track_move')
	track = track:new()
	track:set_log(log)
	track.goback = false

	track.limit = 100000
	textutils.serialise(track)
	track:to(1, 2,  3, true)
	track:to(2, 14, 5, true)
	track:to(1, 2,  9, true)
	track:to(3, 6,  3, true)
	track:to(4, 2, 11, true)
	-- move:to(1, 0, 0, true)
	-- move:to(1, 0, 1, true)
	-- move:to(-2, 0, 1, true)

	local	want = {x = 4, y = 2, z = 11}
	-- local	want = {x = -2, y = 0, z = 1}

	if want.x ~= track.location.x then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.x), tostring(track.location.x))
	end
	if want.y ~= track.location.y then
		log:error('with y\n\t want {} \n\t got {}', tostring(want.y), tostring(track.location.y))
	end
	if want.z ~= track.location.z then
		log:error('with z\n\t want {} \n\t got {}', tostring(want.z), tostring(track.location.z))
	end
end

return {
	init = init,
	movement_test = movement_test,
	retrace_test = retrace_test,
	to_test = to_test,
}

