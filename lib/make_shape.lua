local module = {
	will_place = false,
	force = 0, -- 0 = false and 1 = true
	block = nil,

	ensure = require("../lib.ensure_place"),
	track = require("../lib.track_move")
}

function module:new(track, ensure, block)
	local class = setmetatable({}, self)
	self.__index = self

	self.track = track or self.track
	self.ensure = ensure or self.ensure
	self.block = block

	return class
end

local function round(to_round, decimal_place) -- Needed for Polygons
	local mult = 10 ^ (decimal_place or 0)
	local sign = to_round / math.abs(to_round)
	return sign * math.floor(((math.abs(to_round) * mult) + 0.5)) / mult
end

-- Shape Building functions
function module:draw_line(end_x, end_y, start_x, start_y)
	start_x = start_x or self.track.location.x
	start_y = start_y or self.track.location.z
	local delta_x = math.abs(end_x - start_x)
	local delta_y = math.abs(end_y - start_y)
	local error_var = 0
	if delta_x >= delta_y then
		local delta_err = math.abs(delta_y / delta_x)
		if start_x < end_x then
			if start_y < end_y then
				local counter_y = start_y
				for counter_x = start_x, end_x do
					self.track:to(counter_x, self.track.location.y, counter_y, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					error_var = error_var + delta_err
					if error_var >= 0.5 then
						counter_y = counter_y + 1
						error_var = error_var - 1
					end
				end
			else
				local counter_y = start_y
				for counter_x = start_x, end_x do
					self.track:to(counter_x, self.track.location.y, counter_y, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					error_var = error_var + delta_err
					if error_var >= 0.5 then
						counter_y = counter_y - 1
						error_var = error_var - 1
					end
				end
			end
		else
			if start_y < end_y then
				local counter_y = start_y
				for counter_x = start_x, end_x, -1 do
					self.track:to(counter_x, self.track.location.y, counter_y, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					error_var = error_var + delta_err
					if error_var >= 0.5 then
						counter_y = counter_y + 1
						error_var = error_var - 1
					end
				end
			else
				local counter_y = start_y
				for counter_x = start_x, end_x, -1 do
					self.track:to(counter_x, self.track.location.y, counter_y, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					error_var = error_var + delta_err
					if error_var >= 0.5 then
						counter_y = counter_y - 1
						error_var = error_var - 1
					end
				end
			end
		end
	else
		local delta_err = math.abs(delta_x / delta_y)
		if start_y < end_y then
			if start_x < end_x then
				local counter_x = start_x
				for counter_y = start_y, end_y do
					self.track:to(counter_x, self.track.location.y, counter_y, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					error_var = error_var + delta_err
					if error_var >= 0.5 then
						counter_x = counter_x + 1
						error_var = error_var - 1
					end
				end
			else
				local counter_x = start_x
				for counter_y = start_y, end_y do
					self.track:to(counter_x, self.track.location.y, counter_y, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					error_var = error_var + delta_err
					if error_var >= 0.5 then
						counter_x = counter_x - 1
						error_var = error_var - 1
					end
				end
			end
		else
			if start_x < end_x then
				local counter_x = start_x
				for counter_y = start_y, end_y, -1 do
					self.track:to(counter_x, self.track.location.y, counter_y, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					error_var = error_var + delta_err
					if error_var >= 0.5 then
						counter_x = counter_x + 1
						error_var = error_var - 1
					end
				end
			else
				local counter_x = start_x
				for counter_y = start_y, end_y, -1 do
					self.track:to(counter_x, self.track.location.y, counter_y, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					error_var = error_var + delta_err
					if error_var >= 0.5 then
						counter_x = counter_x - 1
						error_var = error_var - 1
					end
				end
			end
		end
	end
end

function module:rectangle(width, depth, start_x, start_y)
	start_x = start_x or self.track.location.x
	start_y = start_y or self.track.location.z
	local end_x = start_x + width - 1
	local end_y = start_y + depth - 1
	module:draw_line(start_x, end_y, start_x, start_y)
	module:draw_line(end_x, end_y, start_x, end_y)
	module:draw_line(end_x, start_y, end_x, end_y)
	module:draw_line(start_x, start_y, end_x, start_y)
end

function module:square(length, start_x, start_y)
	start_x = start_x or self.track.location.x
	start_y = start_y or self.track.location.z
	module:rectangle(length, length, start_x, start_y)
end

function module:wall(depth, height)
	for i = 1, depth do
		for j = 1, height do
			if self.will_place then
				self.ensure:place()
			end
			if j < height then
				self.track:to(self.track.location.x, self.track.location.y + 1, self.track.location.z, self.force)
			end
		end
		if (i ~= depth) then
			self.track:to(self.track.location.x, self.track.location.y, self.track.location.z + 1, self.force)
		end
	end
end

function module:platform(width, depth, start_x, start_y)
	start_x = start_x or self.track.location.x
	start_y = start_y or self.track.location.z

	local end_x = start_x + width - 1
	local end_y = start_y + depth - 1
	local forward = true
	for counter_y = start_y, end_y do
		if forward then
			for counter_x = start_x, end_x do
				self.track:to(counter_x, self.track.location.y, counter_y, self.force)
				if self.will_place then
					self.ensure:place()
				end
			end
		else
			for counter_x = end_x, start_x, -1 do
				self.track:to(counter_x, self.track.location.y, counter_y, self.force)
				if self.will_place then
					self.ensure:place()
				end
			end
		end
		forward = not forward
	end
end

function module:cuboid(width, depth, height, hollow, start_x, start_z)
	start_x = start_x or self.track.location.x
	start_z = start_z or self.track.location.z
	for i = 0, height - 1 do
		self.track:to(self.track.location.x, i, self.track.location.z, self.force)
		if hollow == "y" then
			module:platform(depth, width, start_x, start_z)
		else
			module:rectangle(depth, width, start_x, start_z)
		end
	end
end

function module:pyramid(length, hollow)
	-- local height = math.ceil(length / 2) - 1
	local i = 0
	while (length > 0) do
		self.track:to(i, i, i, self.force)
		if (hollow == "y") then
			module:rectangle(length, length, i, i)
		else
			module:platform(length, length, i, i)
		end
		i = i + 1
		length = length - 2
	end
end

function module:stair(width, height, start_x, start_y) -- Last two might be able to be used to make a basic home-like shape later?
	start_x = start_x or self.track.location.x
	start_y = start_y or self.track.location.z

	local endX = start_x + width - 1
	local endY = start_y + height - 1
	local forward = true
	for counter_y = start_y, endY do
		if forward then
			for counter_x = start_x, endX do
				self.track:to(counter_x, self.track.location.y, counter_y, self.force)
				if self.will_place then
					self.ensure:place()
				end
			end
		else
			for counter_x = endX, start_x, -1 do
				self.track:to(counter_x, self.track.location.y, counter_y, self.force)
				if self.will_place then
					self.ensure:place()
				end
			end
		end
		if counter_y ~= endY then
			self.track:to(self.track.location.x, self.track.location.y + 1, self.track.location.z, self.force)
			forward = not forward
		end
	end
end

local function block_in_sphere_is_full(offset, x, y, z, radius_sq)
	x = x - offset
	y = y - offset
	z = z - offset
	x = x ^ 2
	y = y ^ 2
	z = z ^ 2
	return x + y + z <= radius_sq
end

local function is_sphere_border(offset, x, y, z, radius_sq)
	local spot = block_in_sphere_is_full(offset, x, y, z, radius_sq)
	if spot then
		spot = not block_in_sphere_is_full(offset, x, y - 1, z, radius_sq) or
			not block_in_sphere_is_full(offset, x, y + 1, z, radius_sq) or
			not block_in_sphere_is_full(offset, x - 1, y, z, radius_sq) or
			not block_in_sphere_is_full(offset, x + 1, y, z, radius_sq) or
			not block_in_sphere_is_full(offset, x, y, z - 1, radius_sq) or
			not block_in_sphere_is_full(offset, x, y, z + 1, radius_sq)
	end
	return spot
end

function module:circle(diameter)
	local odd = not (math.fmod(diameter, 2) == 0)
	local radius = diameter / 2

	local width = 0
	local offset = 0

	if odd then
		width = (2 * math.ceil(radius)) + 1
		offset = math.floor(width / 2)
	else
		width = (2 * math.ceil(radius)) + 2
		offset = math.floor(width / 2) - 0.5
	end

	--diameter --radius * 2 + 1
	-- local sqrt3 = 3 ^ 0.5
	local boundary_radius = radius + 1.0
	local boundary2 = boundary_radius ^ 2
	local radius2 = radius ^ 2
	local z = math.floor(radius)
	local cz2 = (radius - z) ^ 2
	local limit_offset_y = (boundary2 - cz2) ^ 0.5
	local max_offset_y = math.ceil(limit_offset_y)

	local y_start = 0
	local y_end = 0
	local y_step = 0

	local x_start = 0
	local x_end = 0
	local x_step = 0

	-- We do first the +x side, then the -x side to make movement efficient
	for side = 0, 1 do
		-- On the right we go from small y to large y, on the left reversed
		-- This makes us travel clockwise (from below) around each layer
		if (side == 0) then
			y_start = math.floor(radius) - max_offset_y
			y_end = math.floor(radius) + max_offset_y
			y_step = 1
		else
			y_start = math.floor(radius) + max_offset_y
			y_end = math.floor(radius) - max_offset_y
			y_step = -1
		end
		for y = y_start, y_end, y_step do
			local cy2 = (radius - y) ^ 2
			local remainder2 = (boundary2 - cz2 - cy2)
			if remainder2 >= 0 then
				-- This is the maximum difference in x from the centre we can be without definitely being outside the radius
				local max_offset_x = math.ceil((boundary2 - cz2 - cy2) ^ 0.5)
				-- Only do either the +x or -x side
				if (side == 0) then
					-- +x side
					x_start = math.floor(radius)
					x_end = math.floor(radius) + max_offset_x
				else
					-- -x side
					x_start = math.floor(radius) - max_offset_x
					x_end = math.floor(radius) - 1
				end
				-- Reverse direction we traverse xs when in -y side
				if y > math.floor(radius) then
					local temp = x_start
					x_start = x_end
					x_end = temp
					x_step = -1
				else
					x_step = 1
				end

				for x = x_start, x_end, x_step do
					-- Only blocks within the radius but still within 1 3d-diagonal block of the edge are eligible
					if is_sphere_border(offset, x, y, z, radius2) then
						self.track:to(x, self.track.location.y, y, self.force)
						if self.will_place then
							self.ensure:place()
						end
					end
				end
			end
		end
	end
end

function module:dome(typus, diameter)
	-- Main dome and sphere building routine
	local odd = not (math.fmod(diameter, 2) == 0)
	local radius = diameter / 2

	local width = 0
	local offset = 0

	if odd then
		width = (2 * math.ceil(radius)) + 1
		offset = math.floor(width / 2)
	else
		width = (2 * math.ceil(radius)) + 2
		offset = math.floor(width / 2) - 0.5
	end

	--diameter --radius * 2 + 1
	-- local sqrt3 = 3 ^ 0.5
	local boundary_radius = radius + 1.0
	local boundary2 = boundary_radius ^ 2
	local radius2 = radius ^ 2

	local zstart = 0
	local zend = 0

	if typus == "dome" then
		zstart = math.ceil(radius)
	elseif typus == "sphere" then
		zstart = 1
	elseif typus == "bowl" then
		zstart = 1
	end
	if typus == "bowl" then
		zend = math.floor(radius)
	else
		zend = width - 1
	end

	-- This loop is for each vertical layer through the sphere or dome.
	for z = zstart, zend do
		if z ~= zstart then
			self.track:to(self.track.location.x, self.track.location.y + 1, self.track.location.z, self.force)
		end
		--writeOut("Layer " .. z)
		local cz2 = (radius - z) ^ 2
		local limit_offset_y = (boundary2 - cz2) ^ 0.5
		local max_offset_y = math.ceil(limit_offset_y)
		-- We do first the +x side, then the -x side to make movement efficient
		for side = 0, 1 do
			-- On the right we go from small y to large y, on the left reversed
			-- This makes us travel clockwise (from below) around each layer
			local ystart = 0
			local yend = 0
			local ystep = 0

			local xstart = 0
			local xend = 0
			local xstep = 0

			if (side == 0) then
				ystart = math.floor(radius) - max_offset_y
				yend = math.floor(radius) + max_offset_y
				ystep = 1
			else
				ystart = math.floor(radius) + max_offset_y
				yend = math.floor(radius) - max_offset_y
				ystep = -1
			end
			for y = ystart, yend, ystep do
				local cy2 = (radius - y) ^ 2
				local remainder2 = (boundary2 - cz2 - cy2)
				if remainder2 >= 0 then
					-- This is the maximum difference in x from the centre we can be without definitely being outside the radius
					local max_offset_x = math.ceil((boundary2 - cz2 - cy2) ^ 0.5)
					-- Only do either the +x or -x side
					if (side == 0) then
						-- +x side
						xstart = math.floor(radius)
						xend = math.floor(radius) + max_offset_x
					else
						-- -x side
						xstart = math.floor(radius) - max_offset_x
						xend = math.floor(radius) - 1
					end
					-- Reverse direction we traverse xs when in -y side
					if y > math.floor(radius) then
						local temp = xstart
						xstart = xend
						xend = temp
						xstep = -1
					else
						xstep = 1
					end

					for x = xstart, xend, xstep do
						-- Only blocks within the radius but still within 1 3d-diagonal block of the edge are eligible
						if is_sphere_border(offset, x, y, z, radius2) then
							self.track:to(x, z, y, self.force)
							if self.will_place then
								self.ensure:place()
							end
						end
					end
				end
			end
		end
	end
end

function module:cylinder(diameter, height)
	for i = 1, height do
		module:circle(diameter)
		if i ~= height then
			self.track:to(self.track.location.x, self.track.location.y + 1, self.track.location.z, self.force)
		end
	end
end

local function isINF(value)
	return (value == math.huge or value == -math.huge)
end

local function isNAN(value)
	return value ~= value
end

local polygon_corner_list = {} -- Public list of corner coords for n-gons, will be used for hexagons, octagons, and future polygons.
-- It should be a nested list eg. {{x0,y0},{x1,y1},{x2,y2}...}

function module:construct_polygon_from_list() -- Uses polygon_corner_list to draw sides between each point
	if #polygon_corner_list == 0 then
		return false
	end
	for i = 1, #polygon_corner_list do
		if (isINF(polygon_corner_list[i][1]) or isNAN(polygon_corner_list[i][1])) then
			polygon_corner_list[i][1] = 0
		end
		if (isINF(polygon_corner_list[i][2]) or isNAN(polygon_corner_list[i][2])) then
			polygon_corner_list[i][2] = 0
		end
	end
	local j = 0
	for i = 1, #polygon_corner_list do
		local start_x = polygon_corner_list[i][1]
		local start_y = polygon_corner_list[i][2]
		if i == #polygon_corner_list then
			j = 1
		else
			j = i + 1
		end
		local stop_x = polygon_corner_list[j][1]
		local stop_y = polygon_corner_list[j][2]
		module:draw_line(stop_x, stop_y, start_x, start_y)
	end
	return true
end

function module:circle_like_polygon(num_sides, diameter, offset_angle) -- works like the circle code, allows building a circle with the same diameter from the same start point to inscribe the polygon. offset_angle is optional, defaults to 0.
	local radius = diameter / 2
	local start_angle = 0
	if (num_sides % 2 == 1) then                         -- if num_sides is odd
		start_angle = math.pi /
		2                                               -- always have a vertex at 90 deg (+y) and at least one grid aligned edge. Before offset_angle
	else                                                -- if num_sides is even
		start_angle = (math.pi / 2) +
		(math.pi / num_sides)                            -- always have at least two grid aligned edges. Before offset_angle
	end
	start_angle = start_angle + (math.rad(offset_angle or 0)) -- offset_angle will be in degrees

	for i = 1, num_sides do
		polygon_corner_list[i] = { radius * math.cos(start_angle + ((i - 1) * ((math.pi * 2) / num_sides))), radius *
		math.sin(start_angle + ((i - 1) * ((math.pi * 2) / num_sides))) }
	end

	for i = 1, #polygon_corner_list do
		polygon_corner_list[i][1] = round(polygon_corner_list[i][1] + radius + 1)
		polygon_corner_list[i][2] = round(polygon_corner_list[i][2] + radius + 1)
	end

	if not module:construct_polygon_from_list() then
		error("This error should never happen.")
	end
end

function module:polygon(num_sides, side_length, offset_angle) -- offset_angle is optional, defaults to 0.
	local current_angle = 0 + (math.rad(offset_angle or 0))  -- start at 0 or offset angle. offset_angle will be in degrees
	local add_angle = ((math.pi * 2) / num_sides)
	local pointer_x, pointer_y = 0, 0
	side_length = side_length - 1

	for i = 1, num_sides do
		polygon_corner_list[i] = { pointer_x, pointer_y }
		pointer_x = side_length * math.cos(current_angle) + pointer_x
		pointer_y = side_length * math.sin(current_angle) + pointer_y
		current_angle = current_angle + add_angle
	end

	local min_x, min_y = 0, 0
	for i = 1, #polygon_corner_list do -- find the smallest x and y
		if (polygon_corner_list[i][1] <= min_x) then
			min_x = polygon_corner_list[i][1]
		end
		if (polygon_corner_list[i][2] <= min_y) then
			min_y = polygon_corner_list[i][2]
		end
	end
	min_x = math.abs(min_x)         -- should eventually calculate the difference between min_x and 0
	min_y = math.abs(min_y)         -- should eventually calculate the difference between min_y and 0

	for i = 1, #polygon_corner_list do -- make it bounded to 0, 0
		polygon_corner_list[i][1] = round(polygon_corner_list[i][1] + min_x)
		polygon_corner_list[i][2] = round(polygon_corner_list[i][2] + min_y)
	end

	if not module:construct_polygon_from_list() then
		error("This error should never happen.")
	end
end

function module:circle_like_polygon_prism(num_sides, diameter, height, offset_angle)
	offset_angle = offset_angle or 0
	for i = 1, height do
		module:circle_like_polygon(num_sides, diameter, offset_angle)
		if i ~= height then
			self.track:to(self.track.location.x, self.track.location.y + 1, self.track.location.z, self.force)
		end
	end
end

function module:polygon_prism(num_sides, side_length, height, offset_angle)
	offset_angle = offset_angle or 0
	for i = 1, height do
		module:polygon(num_sides, side_length, offset_angle)
		if i ~= height then
			self.track:to(self.track.location.x, self.track.location.y + 1, self.track.location.z, self.force)
		end
	end
end

function module:hexagon(length) -- Deprecated, please use polygon(6, side_length, 0). Fills out polygon_corner_list with the points for a hexagon.
	module:polygon_prism(6, length, 0)
end

function module:octagon(length) -- Deprecated, please use polygon(8, side_length, 0). Fills out polygon_corner_list with the points for an octagon
	module:polygon_prism(8, length, 0)
end

function module:hexagon_prism(length, height) -- Deprecated, please use polygonPrism(6, side_length, height, 0).
	module:polygon_prism(6, length, height, 0)
end

function module:octagon_prism(length, height) -- Deprecated, please use polygonPrism(8, side_length, height, 0).
	module:polygon_prism(8, length, height, 0)
end

return module
