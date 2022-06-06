
-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
-- remember to comment out above before use

local forward_face = 0
local right_face = 1
local back_face = 2
local left_face = 3

local script = {
	x = 0,
	y = 0,
	z = 0,
	dir = forward_face, -- (0, 1, 2, 3) = (forward, right, back, left) relative to starting origin
	trace = {}, -- {x, y, z, dir} for soft retrace
	cost = 0, -- current fuel cost
	limit = 0,
	should_goback = false,
}

local function det_dir(num, sc) -- determine direction

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

local function check_limit(num, sc)
	if sc.limit ~= 0 then
		local next = sc.cost + num

		if next > sc.limit then
			num = next - sc.limit
			sc.limit = 0
			sc.should_goback = true
		end
	end

	return num
end

function script:forward(num, force)
	force = force or true
	num = num or 1

	num = check_limit(num, script)

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
	script.cost = script.cost + count
end

function script:back(num, force)
	force = force or true
	num = num or 1

	num = check_limit(num, script)

	if force then -- yeah so just...
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
	script.cost = script.cost + count
end

function script:up(num, force)
	force = force or true
	num = num or 1

	num = check_limit(num, script)

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
	script.cost = script.cost + count
end

function script:down(num, force)
	force = force or true
	num = num or 1

	num = check_limit(num, script)

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
	script.cost = script.cost + count
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

	print('[info:track] retracing steps using [hard='..tostring(hard)..']')

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

		script:reset_trace(false)
		return
	end

	-- start of soft retrace

	for i = #script.trace, 1, -1 do
		local trace = script.trace[i]

		while script.dir ~= (trace.dir+2) % 4 do
			script:turnLeft(1)
		end

		script:_trace(trace)
	end

	while script.dir ~= forward_face do -- make sure its face forward
		script:turnLeft(1)
	end

	script:reset_trace(false)
end

function script:_trace(trace)
	if trace.y > 0 then
		script:down(trace.y, false)
		return
	elseif trace.y < 0 then
		script:up(trace.y*-1, false)
		return
	end

	-- not suppose to happen but lets check if
	-- we got x position for a z direction and vice versa
	if script.dir % 2 == 0 and trace.z ~= 0 then
		print('[warning:track] got x for z:', script.dir, script.z)
	elseif script.dir % 2 ~= 0 and trace.x ~= 0  then
		print('[warning:track] got z for x:', script.dir, script.x)
	end

	if trace.x ~= 0 then
		local x = trace.x
		if x < 0 then
			x = x * -1
		end

		script:forward(x, false)

		return
	end

	local z = trace.z
	if z < 0 then
		z = z * -1
	end

	script:forward(z, false)
end

function script:reset_trace(hard)
	hard = hard or false -- doesn't reset origin if false

	print('[info:track] reseting trace...')

	if hard then
		script.x = 0
		script.y = 0
		script.z = 0
		script.dir = 0
	end

	for k in pairs(script.trace) do
		script.trace[k] = nil
	end
end

return script

