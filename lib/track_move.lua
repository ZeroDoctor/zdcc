-- #test
local turtle = require("test.turtle_test_api")
-- #end

local careful = require("../lib.careful_dig")
local ensure = require("../lib.ensure_place")
local check = require("../lib.check_inventory")

local log = require("../log.logs")

local forward_face = 0
local right_face = 1
local back_face = 2
local left_face = 3

local script = {
	location = {
		x = 0,
		y = 0,
		z = 0,
		dir = forward_face, -- (0, 1, 2, 3) = (forward, right, back, left) relative to starting origin
	},

	trace = {}, -- {x, y, z, dir} for soft retrace
	before = {},
	hard_reset = false,

	cost = 0, -- current fuel cost
	limit = -1, -- limit of fuel usage. if -1 then ignore limit

	goback = false,
	should_goback = false,
	need_fuel = false,

	auto_place_after = 5,
}

function script:init(care, en, ch)
	careful = care or careful
	check = ch or check
	ensure = en
end

local function det_dir(num, location) -- determine direction

	if location.dir == forward_face then
		location.x = location.x + num
	elseif location.dir == right_face then
		location.z = location.z + num
	elseif location.dir == back_face then
		location.x = location.x - num
	elseif location.dir == left_face then
		location.z = location.z - num
	end

	return location
end

local function check_limit(num, sc) -- check if refuel is needed

	if sc.should_goback then
		local next = sc.cost + num

		if next >= sc.limit then
			num = next - sc.limit
			sc.limit = 0
			sc.need_fuel = true
		end
	else
		sc:check_additional_fuel()
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

		if ensure ~= nil and
			self.auto_place_after ~= 0 and
			(self.cost + count) % self.auto_place_after == 0 then
			ensure:auto()
		end
	end

	-- keep track of movement
	det_dir(count, self.location)
	self.cost = self.cost + count
	if not self.goback then
		table.insert(self.trace, det_dir(count, {x=0, y=0, z=0, dir=self.location.dir}))

		-- retrace steps if limit reached
		if self.should_goback and self.need_fuel then
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

		if ensure ~= nil and
			self.auto_place_after ~= 0 and
			(self.cost + count) % self.auto_place_after == 0 then
			ensure:auto()
		end
	end

	-- keep track of movement
	det_dir(count, self.location)
	self.cost = self.cost + count
	if not self.goback then
		table.insert(self.trace, det_dir(count, {x=0, y=0, z=0, dir=self.location.dir}))

		-- retrace steps if limit reached
		if self.should_goback and self.need_fuel then
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
	for i = 1, num, 1 do
		if force then
			careful:digUp()
		end

		local s = turtle.up()
		if s then
			count = count + 1
		end

		if ensure ~= nil and
			self.auto_place_after ~= 0 and
			(math.abs(self.location.y) + i) % self.auto_place_after == 0 then
			ensure:auto()
		end
	end

	-- keep track of movement
	self.location.y = self.location.y + count
	self.cost = self.cost + count

	if not self.goback then
		table.insert(self.trace, {x=0, y=count, z=0, dir=self.location.dir})

		-- retrace steps if limit reached
		if self.should_goback and self.need_fuel then
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
	for i = 1, num, 1 do
		if force then
			careful:digDown()
		end

		local s = turtle.down()
		if s then
			count = count + 1
		end

		if ensure ~= nil and
			self.auto_place_after ~= 0 and
			(math.abs(self.location.y) + i) % self.auto_place_after == 0 then
			ensure:auto()
		end
	end

	-- keep track of movement
	self.location.y = self.location.y - count
	self.cost = self.cost + count
	if not self.goback then
		table.insert(self.trace, {x=0, y=-count, z=0, dir=self.location.dir})

		-- retrace steps if limit reached
		if self.should_goback and self.need_fuel then
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

	self.location.dir = (self.location.dir-count) % 4
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

	self.location.dir = (self.location.dir+count) % 4
end

function script:turn(face)
	face = face or self.location.dir

	if self.location.dir - 1 == face then
		script:turnLeft()
	end

	while self.location.dir ~= face do
		script:turnRight()
	end
end

function script:while_to(x, y, z, force)
	x = x or 0
	y = y or 0
	z = z or 0
	force = force or false

	if x ~= 0 then
		if x > 0 then
			script:turn(forward_face)
		else
			script:turn(back_face)
		end

		script:forward(x, force)
	end

	if z ~= 0 then
		if z > 0 then
			script:turn(right_face)
		else
			script:turn(left_face)
		end

		script:forward(z, force)
	end

	if y ~= 0 then
		if y > 0 then
			script:up(y, force)
			return
		end

		script:down(y, force)
	end
end

-- to method could be better
function script:to(x, y, z, force)
	x = x or self.location.x
	y = y or self.location.y
	z = z or self.location.z
	force = force or false

	if self.location.dir % 2 == 0 then -- forward or back
		local m = math.abs(x - self.location.x)
		if self.location.x < x then
			script:turn(forward_face)
			script:forward(m, force)
		elseif self.location.x > x then
			script:turn(back_face)
			script:forward(m, force)
		end

		m = math.abs(z - self.location.z)
		if self.location.z < z then
			script:turn(right_face)
			script:forward(m, force)
		elseif self.location.z > z then
			script:turn(left_face)
			script:forward(m, force)
		end
	else -- left or right
		local m = math.abs(z - self.location.z)
		if self.location.z < z then
			script:turn(right_face)
			script:forward(m, force)
		elseif self.location.z > z then
			script:turn(left_face)
			script:forward(m, force)
		end

		m = math.abs(x - self.location.x)
		if self.location.x < x then
			script:turn(forward_face)
			script:forward(m, force)
		elseif self.location.x > x then
			script:turn(back_face)
			script:forward(m, force)
		end
	end

	local m = math.abs(y - self.location.y)
	if self.location.y < y then
		script:up(m, force)
	elseif self.location.y > y then
		script:down(m, force)
	end
end

function script:gobefore()
	if self.before == nil then
		log:warn('{track} before is already nil')
		return
	end

	script:to(self.before[1], self.before[2], self.before[3])
	script:turn(self.before[4])
	self.before = nil
end

function script:retrace(hard)
	hard = hard or false -- always soft retrace to avoid breaking anything undesired

	self.before = {self.location.x, self.location.y, self.location.z, self.location.dir}

	self.goback = true
	log:info('{track} retracing steps [hard={}]', hard)

	if hard then
		while self.location.dir ~= forward_face do -- make sure its facing forward
			script:turnLeft(1)
		end

		if self.location.y > 0 then
			script:down(self.location.y, true)
		elseif self.location.y < 0 then
			script:up(self.location.y*-1, true)
		end

		if self.location.x > 0 then
			script:back(self.location.x, true)
		elseif self.location.x < 0 then
			script:forward(self.location.x*-1, true)
		end

		while self.location.dir ~= right_face do -- make sure its facing right
			script:turnLeft(1)
		end

		if self.location.z > 0 then
			script:back(self.location.z, true)
		elseif self.location.z < 0 then
			script:forward(self.location.z*-1, true)
		end

		while self.location.dir ~= forward_face do -- make sure its facing forward
			script:turnLeft(1)
		end

		script:reset_trace(self.hard_reset)
		return
	end

	-- start of soft retrace

	for i = #self.trace, 1, -1 do
		local trace = self.trace[i]

		while self.location.dir ~= (trace.location.dir+2) % 4 do
			script:turnLeft(1)
		end

		script:_trace(trace)
	end

	while self.location.dir ~= forward_face do -- make sure its face forward
		script:turnLeft(1)
	end

	script:reset_trace(self.hard_reset)
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
	if self.location.dir % 2 == 0 and trace.z ~= 0 then
		log:warn('{track} got x for z [dir={}] [z={}]',
			self.location.dir,
			self.location.z
		)
	elseif self.location.dir % 2 ~= 0 and trace.x ~= 0  then
		log:warn('{track} got z for x [dir={}] [x={}]',
			self.location.dir,
			self.location.x
		)
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

	log:info('{track} reseting trace...')

	self.should_goback = false -- its already back
	self.cost = 0

	if hard then
		self.location.x = 0
		self.location.y = 0
		self.location.z = 0
		self.location.dir = 0
	end

	for k in pairs(self.trace) do
		self.trace[k] = nil
	end

	script:check_additional_fuel()

	if self.should_before then
		self.goback = false
		script:gobefore()
	end
end

function script:check_additional_fuel()
	while turtle.getFuelLevel() == 0 and self.need_fuel do
		log:info('{track} additional pylons (fuel) required... (press enter when pylons added)')
		local _ = io.read()

		check:update()
		local inv = check:search_name('*.coal', true)
		if inv == nil or inv.location[1] == nil then
			inv = check:search_name('*.lava', true)
		elseif inv == nil or inv.location[1] == nil then
			inv = check:search_name('*.charcoal', true)
		end

		if inv ~= nil and inv.location[1] ~= nil then
			turtle.select(inv.location[1])
			turtle.refuel()
		end

		self.limit = turtle.getFuelLevel() / 2
	end

	self.need_fuel = false
end

return script

