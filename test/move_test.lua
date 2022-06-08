
local test = require("test.tbl")
local trace = require("track_move")

local function movement_test()
	print('testing movement test...')
	local script = trace

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

	if want.x ~= script.x then
		print('[error] with x\n\t want '..tostring(want.x)..'\n\t got '..tostring(script.x))
	end
	if want.y ~= script.y then
		print('[error] with y\n\t want '..tostring(want.y)..'\n\t got '..tostring(script.y))
	end
	if want.z ~= script.z then
		print('[error] with z\n\t want '..tostring(want.z)..'\n\t got '..tostring(script.z))
	end
	if want.dir ~= script.dir then
		print('[error] with dir\n\t want '..tostring(want.dir)..'\n\t got '..tostring(script.dir))
	end

	-- print(test.print_table(script))
end

local function retrace_test()
	print('testing soft retace test...')
	local script = trace

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

	script:retrace(false)

	-- print(test.print_table(script))
	-- print(script.x, script.y, script.z, script.dir)

	local want = {
		x = 0,
		y = 0,
		z = 0,
		dir = 0
	}

	if want.x ~= script.x then
		print('[error] with x\n\t want '..tostring(want.x)..'\n\t got '..tostring(script.x))
	end
	if want.y ~= script.y then
		print('[error] with y\n\t want '..tostring(want.y)..'\n\t got '..tostring(script.y))
	end
	if want.z ~= script.z then
		print('[error] with z\n\t want '..tostring(want.z)..'\n\t got '..tostring(script.z))
	end
	if want.dir ~= script.dir then
		print('[error] with dir\n\t want '..tostring(want.dir)..'\n\t got '..tostring(script.dir))
	end

	print('testing hard retace test...')

	script:forward(5) script:turnLeft(3)
	script:forward(4) script:turnLeft(2)
	script:forward(8) script:turnLeft(5)
	script:forward(2) script:turnLeft(1)
	script:forward(3) script:turnLeft(6)
	script:forward(1)
	script:back(3)
	script:forward(1)
	script:up(4)      script:turnRight(1)
	script:up(4)      script:turnRight(1)
	script:forward(9) script:turnRight(7)
	script:forward(2)
	script:down(4)
	script:forward(7) script:turnRight(1)
	script:back(3)

	script:retrace(true)

	if want.x ~= script.x then
		print('[error] with x\n\t want '..tostring(want.x)..'\n\t got '..tostring(script.x))
	end
	if want.y ~= script.y then
		print('[error] with y\n\t want '..tostring(want.y)..'\n\t got '..tostring(script.y))
	end
	if want.z ~= script.z then
		print('[error] with z\n\t want '..tostring(want.z)..'\n\t got '..tostring(script.z))
	end
	if want.dir ~= script.dir then
		print('[error] with dir\n\t want '..tostring(want.dir)..'\n\t got '..tostring(script.dir))
	end
end


return {
	movement_test = movement_test,
	retrace_test = retrace_test
}

