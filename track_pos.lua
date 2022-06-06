
-- remeber to comment this out before use

local test = require('test.table')

local turtle = {
	dig = function() return true end,
	digUp = function() return true end,
	digDown = function() return true end,
	detect = function() return true end,
	detectUp = function() return true end,
	detectDown = function() return true end,
	forward = function() return true, nil end,
	back = function() return true, nil end,
	up = function() return true, nil end,
	down = function() return true, nil end,
	turnLeft = function() return true, nil end,
	turnRight = function() return true, nil end,
}

local forward_face = 0;
local right_face = 1;
local back_face = 2;
local left_face = 3;

local script = {
	x = 0,
	y = 0,
	z = 0,
	dir = forward_face, -- (0, 1, 2, 3) = (forward, right, back, left) relative to starting origin
	trace = {}, -- {x, y, z, dir} for soft retrace
}

local function det_dir(num, sc)

	if sc.dir == forward_face then
		sc.x = sc.x + num
	elseif sc.dir == right_face then
		sc.z = sc.z + num
	elseif sc.dir == back_face then
		sc.x = sc.x - num
	elseif sc.dir == left_face then
		sc.z = sc.z - num
	end

	return sc
end

function script:forward(num, force)
	force = force or true
	num = num or 1

	local count = 0
	for _ = 1, num, 1 do
		if force and turtle.detect() then
			turtle.dig()
		end

		local s = turtle.forward()
		if s then
			count = count + 1
		end
	end

	table.insert(script.trace, det_dir(count, {x=0, y=0, z=0, dir=script.dir}))
	script = det_dir(count, script)
end

function script:back(num, force)
	force = force or true
	num = num or 1

	if force then
		script:turnLeft(2)

		script:forward(num, force)

		script:turnLeft(2)
		return
	end

	local count = 0
	for _ = 1, num, 1 do
		local s = turtle.back()
		if s then
			count = count + 1
		end
	end

	table.insert(script.trace, det_dir(count, {x=0, y=0, z=0, dir=script.dir}))
	script = det_dir(count, script)
end

function script:up(num, force)
	force = force or true
	num = num or 1

	local count = 0
	for _ = 1, num, 1 do
		if force and turtle.detectUp()then
			turtle.digUp()
		end

		local s = turtle.up()
		if s then
			count = count + 1
		end
	end

	table.insert(script.trace, {x=0, y=count, z=0, dir=script.dir})
	script.y = script.y + count
end

function script:down(num, force)
	force = force or true
	num = num or 1

	local count = 0
	for _ = 1, num, 1 do
		if force and turtle.detectDown() then
			turtle.digDown()
		end

		local s = turtle.down()
		if s then
			count = count + 1
		end
	end

	table.insert(script.trace, {x=0, y=-count, z=0, dir=script.dir})
	script.y = script.y - count
end

function script:turnLeft(num)
	num = num or 1

	local count = 0
	for _ = 1, num, 1 do
		local s = turtle.turnLeft()
		if s then
			count = count + 1
		end
	end

	script.dir = (script.dir-count) % 4
end

function script:turnRight(num)
	num = num or 1

	local count = 0
	for _ = 1, num, 1 do
		local s = turtle.turnRight()
		if s then
			count = count + 1
		end
	end

	script.dir = (script.dir+count) % 4
end

function script:retrace(hard)
	hard = hard or false -- always soft retrace to avoid break anything undesired

	if hard then
		while script.dir ~= forward_face do -- make sure its facing forward
			script:turnLeft(1)
		end


		if script.y > 0 then
			script:down(script.y, true)
		elseif script.y < 0 then
			script:up(script.y*-1, true)
		end

		if script.x > 0 then
			script:back(script.x, true)
		elseif script.x < 0 then
			script:forward(script.x*-1, true)
		end

		while script.dir ~= right_face do -- make sure its facing right
			script:turnLeft(1)
		end

		if script.z > 0 then
			script:back(script.z, true)
		elseif script.z < 0 then
			script:forward(script.z*-1, true)
		end

		while script.dir ~= forward_face do -- make sure its facing forward
			script:turnLeft(1)
		end

		return
	end

	for i = #script.trace, 1, -1 do
		local trace = script.trace[i]

		if trace.y > 0 then
			script:down(trace.y, true)
			goto continue
		elseif script.y < 0 then
			script:up(script.y*-1, true)
			goto continue
		end

		while script.dir ~= (trace.dir+2) % 4 do
			script.turnLeft(1)
		end

		if trace.dir % 2 == 0 then
			local old = trace.x
			if trace.x > 0 then
				script:back(trace.x, true)
			elseif trace.x < 0 then
				script:forward(trace.x*-1, true)
			end

			print('current_dir: '..tostring(script.dir)..
				' trace_dir: '..tostring(trace.dir)..
				' trace_x: '..tostring(trace.x)..
				' old_trace_x: '..tostring(old)
			)
			goto continue
		end

		if trace.z > 0 then
			script:back(trace.z, true)
		elseif trace.z < 0 then
			script:forward(trace.z*-1, true)
		end

		::continue::
	end

end

local function movement_test()
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

	script:retrace(false)
	print(script.x, script.y, script.z)

	-- print(test.print_table(script))
end

-- movement_test()
retrace_test()

return script

