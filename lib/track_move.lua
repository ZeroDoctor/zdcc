-- #test
local turtle = require("test.turtle_test_api")
-- #end

local log = require("../log.logs")

local forward_face = 0
local right_face = 1
local back_face = 2
local left_face = 3

local module = {
	location = {
		x = 0,
		y = 0,
		z = 0,
		dir = forward_face, -- (0, 1, 2, 3) = (forward, right, back, left) relative to starting origin
	},

	trace = {}, -- {x, y, z, dir} for soft retrace
	hard_reset = 0, -- 0 = false and 1 = true

	cost = 0, -- current fuel cost
	limit = -1, -- limit of fuel usage. if -1 then ignore limit

	goback = false,
	need_fuel = false,

	careful = require("../lib.careful_dig"),
	ensure = require("../lib.ensure_place"),
	check = require("../lib.check_inventory"),

	auto_place_after = 0,
}

function module:new(careful, ensure, check)
	local class = setmetatable({}, self)
	self.__index = self

	self.careful = careful or self.careful
	self.ensure = ensure or self.ensure
	self.check = check or self.check

	return class
end

function module:set_log(p_log) log = p_log end

local function track_dir(num, location) -- determine direction

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

function module:check_limit(num) -- check if refuel is needed
	log:trace('{move:check_limit} checking additional fuel...')
	module:check_additional_fuel()

	return num
end

function module:forward(num, force)
	force = force or 1
	num = num or 1

	-- ensure we have enough fuel
	num = module:check_limit(num)

	-- start moving
	local count = 0
	for _ = 1, num, 1 do
		if force == 1 then
			self.careful:dig()
		end

		if turtle.forward() then
			count = count + 1
		end

		if self.ensure ~= nil and
			self.auto_place_after ~= 0 and
			(self.cost + count) % self.auto_place_after == 0 then
			self.ensure:auto()
		end
	end

	-- keep track of movement
	track_dir(count, self.location)
	self.cost = self.cost + count
	if not self.goback then
		table.insert(self.trace, track_dir(count, {x=0, y=0, z=0, dir=self.location.dir}))

		-- retrace steps if limit reached
		if self.need_fuel then
			module:retrace(self.hard_reset)
		end
	end
end

function module:back(num, force)
	force = force or 1
	num = num or 1

	-- ensure we have enough fuel
	num = module:check_limit(num)

	-- start moving
	if force == 1 then
		module:turn_left(2)

		module:forward(num, force)

		module:turn_left(2)

		return -- movement already tracked in forward
	end

	local count = 0
	for _ = 1, num, 1 do
		if turtle.back() then
			count = count + 1
		end

		if self.ensure ~= nil and
			self.auto_place_after ~= 0 and
			(self.cost + count) % self.auto_place_after == 0 then
			self.ensure:auto()
		end
	end

	-- keep track of movement
	track_dir(count, self.location)
	self.cost = self.cost + count
	if not self.goback then
		table.insert(self.trace, track_dir(count, {x=0, y=0, z=0, dir=self.location.dir}))

		-- retrace steps if limit reached
		if self.need_fuel then
			module:retrace(self.hard_reset)
		end
	end
end

function module:up(num, force)
	force = force or 1
	num = num or 1

	-- ensure we have enough fuel
	num = module:check_limit(num)

	-- start moving
	local count = 0
	for i = 1, num, 1 do
		if force == 1 then
			self.careful:digUp()
		end

		if turtle.up() then
			count = count + 1
		end

		if self.ensure ~= nil and
			self.auto_place_after ~= 0 and
			(math.abs(self.location.y) + i) % self.auto_place_after == 0 then
			self.ensure:auto()
		end
	end

	-- keep track of movement
	self.location.y = self.location.y + count
	self.cost = self.cost + count

	if not self.goback then
		table.insert(self.trace, {x=0, y=count, z=0, dir=self.location.dir})

		-- retrace steps if limit reached
		if self.need_fuel then
			module:retrace(self.hard_reset)
		end
	end
end

function module:down(num, force)
	force = force or 1
	num = num or 1

	-- ensure we have enough fuel
	num = module:check_limit(num)

	-- start moving
	local count = 0
	for i = 1, num, 1 do
		if force == 1 then
			self.careful:digDown()
		end

		if turtle.down() then
			count = count + 1
		end

		if self.ensure ~= nil and
			self.auto_place_after ~= 0 and
			(math.abs(self.location.y) + i) % self.auto_place_after == 0 then
			self.ensure:auto()
		end
	end

	-- keep track of movement
	self.location.y = self.location.y - count
	self.cost = self.cost + count
	if not self.goback then
		table.insert(self.trace, {x=0, y=-count, z=0, dir=self.location.dir})

		-- retrace steps if limit reached
		if self.need_fuel then
			module:retrace(self.hard_reset)
		end
	end
end

function module:turn_left(num)
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

function module:turn_right(num)
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

function module:turn(face)
	face = face or self.location.dir

	if self.location.dir - 1 == face then
		module:turn_left()
	end

	while self.location.dir ~= face do
		module:turn_right()
	end
end

function module:while_to(x, y, z, force)
	x = x or 0
	y = y or 0
	z = z or 0
	force = force or 0

	if x ~= 0 then
		if x > 0 then
			module:turn(forward_face)
		else
			module:turn(back_face)
		end

		module:forward(x, force)
	end

	if z ~= 0 then
		if z > 0 then
			module:turn(right_face)
		else
			module:turn(left_face)
		end

		module:forward(z, force)
	end

	if y ~= 0 then
		if y > 0 then
			module:up(y, force)
			return
		end

		module:down(y, force)
	end
end

-- to method could be better
function module:to(x, y, z, force)
	x = x or self.location.x
	y = y or self.location.y
	z = z or self.location.z
	force = force or 0

	if self.location.dir % 2 == 0 then -- forward or back
		local m = math.abs(x - self.location.x)
		if self.location.x < x then
			module:turn(forward_face)
			module:forward(m, force)
		elseif self.location.x > x then
			module:turn(back_face)
			module:forward(m, force)
		end

		m = math.abs(z - self.location.z)
		if self.location.z < z then
			module:turn(right_face)
			module:forward(m, force)
		elseif self.location.z > z then
			module:turn(left_face)
			module:forward(m, force)
		end
	else -- left or right
		local m = math.abs(z - self.location.z)
		if self.location.z < z then
			module:turn(right_face)
			module:forward(m, force)
		elseif self.location.z > z then
			module:turn(left_face)
			module:forward(m, force)
		end

		m = math.abs(x - self.location.x)
		if self.location.x < x then
			module:turn(forward_face)
			module:forward(m, force)
		elseif self.location.x > x then
			module:turn(back_face)
			module:forward(m, force)
		end
	end

	local m = math.abs(y - self.location.y)
	if self.location.y < y then
		module:up(m, force)
	elseif self.location.y > y then
		module:down(m, force)
	end
end

function module:get_location()
	return self.location
end

function module:retrace(hard)
	hard = hard or 0 -- always soft retrace to avoid breaking anything undesired

	self.goback = true
	log:info('{move:retrace} retracing steps [hard={}]', hard)

	if hard == 1 then
		while self.location.dir ~= forward_face do -- make sure its facing forward
			module:turn_left(1)
		end

		if self.location.y > 0 then
			module:down(self.location.y, hard)
		elseif self.location.y < 0 then
			module:up(self.location.y*-1, hard)
		end

		if self.location.x > 0 then
			module:back(self.location.x, hard)
		elseif self.location.x < 0 then
			module:forward(self.location.x*-1, hard)
		end

		while self.location.dir ~= right_face do -- make sure its facing right
			module:turn_left(1)
		end

		if self.location.z > 0 then
			module:back(self.location.z, hard)
		elseif self.location.z < 0 then
			module:forward(self.location.z*-1, hard)
		end

		while self.location.dir ~= forward_face do -- make sure its facing forward
			module:turn_left(1)
		end

		module:reset_trace(self.hard_reset)
		return
	end

	-- start of soft retrace
	for i = #self.trace, 1, -1 do
		local trace = self.trace[i]

		while self.location.dir ~= (trace.dir+2) % 4 do
			module:turn_left(1)
		end

		module:_trace(trace)
	end

	while self.location.dir ~= forward_face do -- make sure its face forward
		module:turn_left(1)
	end

	module:reset_trace(self.hard_reset)
end

function module:_trace(trace)
	if trace.y > 0 then
		module:down(trace.y, 0)
		return
	elseif trace.y < 0 then
		module:up(trace.y*-1, 0)
		return
	end

	-- not suppose to happen but lets check if
	-- we got x position for a z direction and vice versa
	if self.location.dir % 2 == 0 and trace.z ~= 0 then
		log:warn('{move:_trace} got x for z [dir={}] [z={}]',
			self.location.dir,
			self.location.z
		)
	elseif self.location.dir % 2 ~= 0 and trace.x ~= 0  then
		log:warn('{move:_trace} got z for x [dir={}] [x={}]',
			self.location.dir,
			self.location.x
		)
	end

	if trace.x ~= 0 then
		local x = trace.x
		if x < 0 then
			x = x * -1
		end

		module:forward(x, 0)
		return
	end

	local z = trace.z
	if z < 0 then
		z = z * -1
	end

	module:forward(z, 0)
end

function module:reset_trace(hard)
	hard = hard or 0 -- doesn't reset origin if false

	log:info('{move:reset_trace} reseting trace...')

	self.cost = 0

	if hard == 1 then
		self.location.x = 0
		self.location.y = 0
		self.location.z = 0
		self.location.dir = 0
	end

	for k in pairs(self.trace) do
		self.trace[k] = nil
	end

	module:check_additional_fuel()
end

function module:check_additional_fuel()
	while turtle.getFuelLevel() == 0 and self.need_fuel do
		log:info('{move:check_additional_fuel} additional pylons (fuel) required... (press enter when pylons added)')
		local _ = io.read()

		self.check:update()
		local inv = self.check:search_name({'*.coal', '*.lava', '*.charcoal'}, true)
		if inv ~= nil and inv.location[1] ~= nil then
			turtle.select(inv.location[1])
			turtle.refuel()
		end

		self.limit = turtle.getFuelLevel() / 2
	end

	self.need_fuel = false
end

return module

