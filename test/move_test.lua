
local textutils = require("test.textutils_test")
local log = require('./log.logs')

local function movement_test()
	local script = require('../lib.track_move')
	script.log = log
	script:init()

	script:forward(5) script:turnLeft(3)
	script:forward(4) script:turnLeft(2)
	script:forward(7) script:turnLeft(5)
	script:forward(1)
	script:back(3)
	script:forward(1)
	script:up(4)      script:turnRight(1)
	script:forward(9) script:turnRight(1)
	script:back(3)
	script:forward(2)
	script:down(3)

	local want = {
		x = 5,
		y = 1,
		z = -12,
		dir = 0
	}

	if want.x ~= script.location.x then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.x), tostring(script.location.x))
	end
	if want.y ~= script.location.y then
		log:error('with y\n\t want {} \n\t got {}', tostring(want.y), tostring(script.location.y))
	end
	if want.z ~= script.location.z then
		log:error('with z\n\t want {} \n\t got {}', tostring(want.z), tostring(script.location.z))
	end
	if want.dir ~= script.location.dir then
		log:error('with dir\n\t want {} \n\t got {}', tostring(want.dir), tostring(script.location.dir))
	end

	-- print(test.print_table(script))
end

local function retrace_test()
	log:info('testing soft retace test...')
	local script = require('../lib.track_move')

	script:forward(5) script:turnLeft(3)
	script:forward(4) script:turnLeft(2)
	script:forward(8) script:turnLeft(5)
	script:forward(8) script:turnLeft(5)
	script:forward(1)
	script:back(3)
	script:forward(1)
	script:up(4)      script:turnRight(1)
	script:up(4)      script:turnRight(1)
	script:forward(9) script:turnRight(7)
	script:back(3)
	script:forward(2)
	script:down(4)
	script:forward(9) script:turnRight(2)
	script:forward(7) script:turnRight(1)

	script:retrace(0)

	-- print(textutils.serialise(script))
	-- print(script.x, script.y, script.z, script.dir)

	local want = {
		x = 0,
		y = 0,
		z = 0,
		dir = 0
	}

	if want.x ~= script.location.x then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.x), tostring(script.location.x))
	end
	if want.y ~= script.location.y then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.y), tostring(script.location.y))
	end
	if want.z ~= script.location.z then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.z), tostring(script.location.z))
	end
	if want.dir ~= script.location.dir then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.dir), tostring(script.location.dir))
	end

	log:info('testing hard retace test...')

	script:forward(5) -- 5 0 0
	script:turnLeft(3) script:forward(4) -- 5 0 4
	script:turnLeft(2) script:forward(8) -- 5 0 -4
	script:turnLeft(5) script:forward(2) -- 3 0 -4
	script:turnLeft(1) script:forward(3) -- 3 0 -1
	script:turnLeft(6) script:forward(1) -- 3 0 -2
	script:back(3) -- 3 0 1 
	script:forward(1) -- 3 0 0
	script:up(4) -- 3 4 0
	script:turnRight(1) script:up(4) -- 3 8 0
	script:turnRight(1) script:forward(9) -- 3 8 9
	script:turnRight(7) script:forward(2) -- 5 8 9
	script:down(4) -- 1 4 9
	script:turnRight(1) script:forward(7) -- 5 4 16
	script:back(3) -- 5 4 13

	script:retrace(1)

	if want.x ~= script.location.x then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.x), tostring(script.location.x))
	end
	if want.y ~= script.location.y then
		log:error('with y\n\t want {} \n\t got {}', tostring(want.y), tostring(script.location.y))
	end
	if want.z ~= script.location.z then
		log:error('with z\n\t want {} \n\t got {}', tostring(want.z), tostring(script.location.z))
	end
	if want.dir ~= script.location.dir then
		log:error('with dir\n\t want {} \n\t got {}', tostring(want.dir), tostring(script.location.dir))
	end
end

local function to_test()
	local script = require('../lib.track_move')

	script.limit = 100000
	textutils.serialise(script)
	script:to(1, 2,  3, true)
	script:to(2, 14, 5, true)
	script:to(1, 2,  9, true)
	script:to(3, 6,  3, true)
	script:to(4, 2, 11, true)
	-- move:to(1, 0, 0, true)
	-- move:to(1, 0, 1, true)
	-- move:to(-2, 0, 1, true)

	local	want = {x = 4, y = 2, z = 11}
	-- local	want = {x = -2, y = 0, z = 1}

	if want.x ~= script.location.x then
		log:error('with x\n\t want {} \n\t got {}', tostring(want.x), tostring(script.location.x))
	end
	if want.y ~= script.location.y then
		log:error('with y\n\t want {} \n\t got {}', tostring(want.y), tostring(script.location.y))
	end
	if want.z ~= script.location.z then
		log:error('with z\n\t want {} \n\t got {}', tostring(want.z), tostring(script.location.z))
	end
end

return {
	movement_test = movement_test,
	retrace_test = retrace_test,
	to_test = to_test,
}

