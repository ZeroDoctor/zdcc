
-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
-- remember to comment out above before use

local careful = require("careful_dig")
local ensure = require("ensure_place")

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
	hard_reset = false,

	cost = 0, -- current fuel cost
	limit = 0, -- limit of fuel usage

	goback = false,
	should_goback = false,

	auto_place_after = 5,
}

function script:init(care, en)
	careful = care
	ensure = en
end

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

local function check_limit(num, sc) -- check if refuel is needed
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

	-- ensure we have enough fuel
	num = check_limit(num, self)

	-- start moving
	local count = 0
	for _ = 1, num, 1 do
		if force then
			careful:dig()
		end

		local s = turtle.forward()
		if s then
			count = count + 1
		end
	end

	-- keep track of movement
	det_dir(count, self)
	self.cost = self.cost + count
	if not self.goback then
		table.insert(self.trace, det_dir(count, {x=0, y=0, z=0, dir=self.dir}))

		-- retrace steps if limit reached
		if self.should_goback then
			script:retrace(self.hard_reset)
		end
	end
end

function script:back(num, force)
	force = force or true
	num = num or 1

	-- ensure we have enough fuel
	num = check_limit(num, self)

	-- start moving
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

	-- keep track of movement
	det_dir(count, self)
	self.cost = self.cost + count
	if not self.goback then
		table.insert(self.trace, det_dir(count, {x=0, y=0, z=0, dir=self.dir}))

		-- retrace steps if limit reached
		if self.should_goback then
			script:retrace(self.hard_reset)
		end
	end
end

function script:up(num, force)
	force = force or true
	num = num or 1

	-- ensure we have enough fuel
	num = check_limit(num, self)

	-- start moving
	local count = 0
	for _ = 1, num, 1 do
		if force then
			careful:digUp()
		end

		local s = turtle.up()
		if s then
			count = count + 1
		end
	end

	-- keep track of movement
	self.y = self.y + count
	self.cost = self.cost + count

	if not self.goback then
		table.insert(self.trace, {x=0, y=count, z=0, dir=self.dir})

		-- retrace steps if limit reached
		if self.should_goback and not self.goback then
			script:retrace(self.hard_reset)
		end
	end
end

function script:down(num, force)
	force = force or true
	num = num or 1

	-- ensure we have enough fuel
	num = check_limit(num, self)

	-- start moving
	local count = 0
	for _ = 1, num, 1 do
		if force then
			careful:digDown()
		end

		local s = turtle.down()
		if s then
			count = count + 1
		end
	end

	-- keep track of movement
	self.y = self.y - count
	self.cost = self.cost + count
	if not self.goback then
		table.insert(self.trace, {x=0, y=-count, z=0, dir=self.dir})

		-- retrace steps if limit reached
		if self.should_goback then
			script:retrace(self.hard_reset)
		end
	end
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

	self.dir = (self.dir-count) % 4
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

	self.dir = (self.dir+count) % 4
end

function script:retrace(hard)
	hard = hard or false -- always soft retrace to avoid breaking anything undesired

	self.goback = true
	print('[info:track] retracing steps using [hard='..tostring(hard)..']')

	if hard then
		while self.dir ~= forward_face do -- make sure its facing forward
			script:turnLeft(1)
		end

		if self.y > 0 then
			script:down(self.y, true)
		elseif self.y < 0 then
			script:up(self.y*-1, true)
		end

		if self.x > 0 then
			script:back(self.x, true)
		elseif self.x < 0 then
			script:forward(self.x*-1, true)
		end

		while self.dir ~= right_face do -- make sure its facing right
			script:turnLeft(1)
		end

		if self.z > 0 then
			script:back(self.z, true)
		elseif self.z < 0 then
			script:forward(self.z*-1, true)
		end

		while self.dir ~= forward_face do -- make sure its facing forward
			script:turnLeft(1)
		end

		script:reset_trace(false)
		return
	end

	-- start of soft retrace

	for i = #self.trace, 1, -1 do
		local trace = self.trace[i]

		while self.dir ~= (trace.dir+2) % 4 do
			script:turnLeft(1)
		end

		script:_trace(trace)
	end

	while self.dir ~= forward_face do -- make sure its face forward
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
	if self.dir % 2 == 0 and trace.z ~= 0 then
		print('[warning:track] got x for z:', self.dir, self.z)
	elseif self.dir % 2 ~= 0 and trace.x ~= 0  then
		print('[warning:track] got z for x:', self.dir, self.x)
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

	self.should_goback = false
	self.cost = 0

	if hard then
		self.x = 0
		self.y = 0
		self.z = 0
		self.dir = 0
	end

	for k in pairs(self.trace) do
		self.trace[k] = nil
	end
end

return script

