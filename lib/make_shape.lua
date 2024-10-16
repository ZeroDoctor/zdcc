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
	local errorVar = 0
	if delta_x >= delta_y then
		local delta_err = math.abs(delta_y / delta_x)
		if start_x < end_x then
			if start_y < end_y then
				local counterY = start_y
				for counterX = start_x, end_x do
					self.track:to(counterX, self.track.location.y, counterY, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					errorVar = errorVar + delta_err
					if errorVar >= 0.5 then
						counterY = counterY + 1
						errorVar = errorVar - 1
					end
				end
			else
				local counterY = start_y
				for counterX = start_x, end_x do
					self.track:to(counterX, self.track.location.y, counterY, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					errorVar = errorVar + delta_err
					if errorVar >= 0.5 then
						counterY = counterY - 1
						errorVar = errorVar - 1
					end
				end
			end
		else
			if start_y < end_y then
				local counterY = start_y
				for counterX = start_x, end_x, -1 do
					self.track:to(counterX, self.track.location.y, counterY, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					errorVar = errorVar + delta_err
					if errorVar >= 0.5 then
						counterY = counterY + 1
						errorVar = errorVar - 1
					end
				end
			else
				local counterY = start_y
				for counterX = start_x, end_x, -1 do
					self.track:to(counterX, self.track.location.y, counterY, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					errorVar = errorVar + delta_err
					if errorVar >= 0.5 then
						counterY = counterY - 1
						errorVar = errorVar - 1
					end
				end
			end
		end
	else
		local deltaErr = math.abs(delta_x / delta_y)
		if start_y < end_y then
			if start_x < end_x then
				local counterX = start_x
				for counterY = start_y, end_y do
					self.track:to(counterX, self.track.location.y, counterY, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					errorVar = errorVar + deltaErr
					if errorVar >= 0.5 then
						counterX = counterX + 1
						errorVar = errorVar - 1
					end
				end
			else
				local counterX = start_x
				for counterY = start_y, end_y do
					self.track:to(counterX, self.track.location.y, counterY, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					errorVar = errorVar + deltaErr
					if errorVar >= 0.5 then
						counterX = counterX - 1
						errorVar = errorVar - 1
					end
				end
			end
		else
			if start_x < end_x then
				local counterX = start_x
				for counterY = start_y, end_y, -1 do
					self.track:to(counterX, self.track.location.y, counterY, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					errorVar = errorVar + deltaErr
					if errorVar >= 0.5 then
						counterX = counterX + 1
						errorVar = errorVar - 1
					end
				end
			else
				local counterX = start_x
				for counterY = start_y, end_y, -1 do
					self.track:to(counterX, self.track.location.y, counterY, self.force)
					if self.will_place then
						self.track:turn_left(2)
						self.ensure:place(self.block)
						self.track:turn_left(2)
					end
					errorVar = errorVar + deltaErr
					if errorVar >= 0.5 then
						counterX = counterX - 1
						errorVar = errorVar - 1
					end
				end
			end
		end
	end
end

function module:rectangle(width, depth, startX, startY)
	startX = startX or self.track.location.x
	startY = startY or self.track.location.z
	local endX = startX + width - 1
	local endY = startY + depth - 1
	module:draw_line(startX, endY, startX, startY)
	module:draw_line(endX, endY, startX, endY)
	module:draw_line(endX, startY, endX, endY)
	module:draw_line(startX, startY, endX, startY)
end

function module:square(length, startX, startY)
	startX = startX or self.track.location.x
	startY = startY or self.track.location.z
	module:rectangle(length, length, startX, startY)
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

function module:platform(width, depth, startX, startY)
	startX = startX or self.track.location.x
	startY = startY or self.track.location.z

	local endX = startX + width - 1
	local endY = startY + depth - 1
	local forward = true
	for counterY = startY, endY do
		if forward then
			for counterX = startX, endX do
				self.track:to(counterX, self.track.location.y, counterY, self.force)
				if self.will_place then
					self.ensure:place()
				end
			end
		else
			for counterX = endX, startX, -1 do
				self.track:to(counterX, self.track.location.y, counterY, self.force)
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

function module:stair(width, height, startX, startY) -- Last two might be able to be used to make a basic home-like shape later?
	startX = startX or self.track.location.x
	startY = startY or self.track.location.z

	local endX = startX + width - 1
	local endY = startY + height - 1
	local forward = true
	for counterY = startY, endY do
		if forward then
			for counterX = startX, endX do
				self.track:to(counterX, self.track.location.y, counterY, self.force)
				if self.will_place then
					self.ensure:place()
				end
			end
		else
			for counterX = endX, startX, -1 do
				self.track:to(counterX, self.track.location.y, counterY, self.force)
				if self.will_place then
					self.ensure:place()
				end
			end
		end
		if counterY ~= endY then
			self.track:to(self.track.location.x, self.track.location.y + 1, self.track.location.z, self.force)
			forward = not forward
		end
	end
end

local function block_in_sphere_is_full(offset, x, y, z, radiusSq)
	x = x - offset
	y = y - offset
	z = z - offset
	x = x ^ 2
	y = y ^ 2
	z = z ^ 2
	return x + y + z <= radiusSq
end

local function is_sphere_border(offset, x, y, z, radiusSq)
	local spot = block_in_sphere_is_full(offset, x, y, z, radiusSq)
	if spot then
		spot = not block_in_sphere_is_full(offset, x, y - 1, z, radiusSq) or
			not block_in_sphere_is_full(offset, x, y + 1, z, radiusSq) or
			not block_in_sphere_is_full(offset, x - 1, y, z, radiusSq) or
			not block_in_sphere_is_full(offset, x + 1, y, z, radiusSq) or
			not block_in_sphere_is_full(offset, x, y, z - 1, radiusSq) or
			not block_in_sphere_is_full(offset, x, y, z + 1, radiusSq)
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
	local boundaryRadius = radius + 1.0
	local boundary2 = boundaryRadius ^ 2
	local radius2 = radius ^ 2
	local z = math.floor(radius)
	local cz2 = (radius - z) ^ 2
	local limitOffsetY = (boundary2 - cz2) ^ 0.5
	local maxOffsetY = math.ceil(limitOffsetY)

	local yStart = 0
	local yEnd = 0
	local yStep = 0

	local xStart = 0
	local xEnd = 0
	local xStep = 0

	-- We do first the +x side, then the -x side to make movement efficient
	for side = 0, 1 do
		-- On the right we go from small y to large y, on the left reversed
		-- This makes us travel clockwise (from below) around each layer
		if (side == 0) then
			yStart = math.floor(radius) - maxOffsetY
			yEnd = math.floor(radius) + maxOffsetY
			yStep = 1
		else
			yStart = math.floor(radius) + maxOffsetY
			yEnd = math.floor(radius) - maxOffsetY
			yStep = -1
		end
		for y = yStart, yEnd, yStep do
			local cy2 = (radius - y) ^ 2
			local remainder2 = (boundary2 - cz2 - cy2)
			if remainder2 >= 0 then
				-- This is the maximum difference in x from the centre we can be without definitely being outside the radius
				local maxOffsetX = math.ceil((boundary2 - cz2 - cy2) ^ 0.5)
				-- Only do either the +x or -x side
				if (side == 0) then
					-- +x side
					xStart = math.floor(radius)
					xEnd = math.floor(radius) + maxOffsetX
				else
					-- -x side
					xStart = math.floor(radius) - maxOffsetX
					xEnd = math.floor(radius) - 1
				end
				-- Reverse direction we traverse xs when in -y side
				if y > math.floor(radius) then
					local temp = xStart
					xStart = xEnd
					xEnd = temp
					xStep = -1
				else
					xStep = 1
				end

				for x = xStart, xEnd, xStep do
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
	local boundaryRadius = radius + 1.0
	local boundary2 = boundaryRadius ^ 2
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
		local limitOffsetY = (boundary2 - cz2) ^ 0.5
		local maxOffsetY = math.ceil(limitOffsetY)
		-- We do first the +x side, then the -x side to make movement efficient
		for side = 0, 1 do
			-- On the right we go from small y to large y, on the left reversed
			-- This makes us travel clockwise (from below) around each layer
			local yStart = 0
			local yEnd = 0
			local yStep = 0

			local xStart = 0
			local xEnd = 0
			local xStep = 0

			if (side == 0) then
				yStart = math.floor(radius) - maxOffsetY
				yEnd = math.floor(radius) + maxOffsetY
				yStep = 1
			else
				yStart = math.floor(radius) + maxOffsetY
				yEnd = math.floor(radius) - maxOffsetY
				yStep = -1
			end
			for y = yStart, yEnd, yStep do
				local cy2 = (radius - y) ^ 2
				local remainder2 = (boundary2 - cz2 - cy2)
				if remainder2 >= 0 then
					-- This is the maximum difference in x from the centre we can be without definitely being outside the radius
					local maxOffsetX = math.ceil((boundary2 - cz2 - cy2) ^ 0.5)
					-- Only do either the +x or -x side
					if (side == 0) then
						-- +x side
						xStart = math.floor(radius)
						xEnd = math.floor(radius) + maxOffsetX
					else
						-- -x side
						xStart = math.floor(radius) - maxOffsetX
						xEnd = math.floor(radius) - 1
					end
					-- Reverse direction we traverse xs when in -y side
					if y > math.floor(radius) then
						local temp = xStart
						xStart = xEnd
						xEnd = temp
						xStep = -1
					else
						xStep = 1
					end

					for x = xStart, xEnd, xStep do
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

local polygonCornerList = {} -- Public list of corner coords for n-gons, will be used for hexagons, octagons, and future polygons.
-- It should be a nested list eg. {{x0,y0},{x1,y1},{x2,y2}...}

function module:construct_polygon_from_list() -- Uses polygonCornerList to draw sides between each point
	if #polygonCornerList == 0 then
		return false
	end
	for i = 1, #polygonCornerList do
		if (isINF(polygonCornerList[i][1]) or isNAN(polygonCornerList[i][1])) then
			polygonCornerList[i][1] = 0
		end
		if (isINF(polygonCornerList[i][2]) or isNAN(polygonCornerList[i][2])) then
			polygonCornerList[i][2] = 0
		end
	end
	local j = 0
	for i = 1, #polygonCornerList do
		local startX = polygonCornerList[i][1]
		local startY = polygonCornerList[i][2]
		if i == #polygonCornerList then
			j = 1
		else
			j = i + 1
		end
		local stopX = polygonCornerList[j][1]
		local stopY = polygonCornerList[j][2]
		module:draw_line(stopX, stopY, startX, startY)
	end
	return true
end

function module:circle_like_polygon(numSides, diameter, offsetAngle) -- works like the circle code, allows building a circle with the same diameter from the same start point to inscribe the polygon. offSetAngle is optional, defaults to 0.
	local radius = diameter / 2
	local startAngle = 0
	if (numSides % 2 == 1) then                         -- if numSides is odd
		startAngle = math.pi /
		2                                               -- always have a vertex at 90 deg (+y) and at least one grid aligned edge. Before offSetAngle
	else                                                -- if numSides is even
		startAngle = (math.pi / 2) +
		(math.pi / numSides)                            -- always have at least two grid aligned edges. Before offSetAngle
	end
	startAngle = startAngle + (math.rad(offsetAngle or 0)) -- offsetAngle will be in degrees

	for i = 1, numSides do
		polygonCornerList[i] = { radius * math.cos(startAngle + ((i - 1) * ((math.pi * 2) / numSides))), radius *
		math.sin(startAngle + ((i - 1) * ((math.pi * 2) / numSides))) }
	end

	for i = 1, #polygonCornerList do
		polygonCornerList[i][1] = round(polygonCornerList[i][1] + radius + 1)
		polygonCornerList[i][2] = round(polygonCornerList[i][2] + radius + 1)
	end

	if not module:construct_polygon_from_list() then
		error("This error should never happen.")
	end
end

function module:polygon(numSides, sideLength, offsetAngle) -- offSetAngle is optional, defaults to 0.
	local currentAngle = 0 + (math.rad(offsetAngle or 0))  -- start at 0 or offset angle. offsetAngle will be in degrees
	local addAngle = ((math.pi * 2) / numSides)
	local pointerX, pointerY = 0, 0
	sideLength = sideLength - 1

	for i = 1, numSides do
		polygonCornerList[i] = { pointerX, pointerY }
		pointerX = sideLength * math.cos(currentAngle) + pointerX
		pointerY = sideLength * math.sin(currentAngle) + pointerY
		currentAngle = currentAngle + addAngle
	end

	local minX, minY = 0, 0
	for i = 1, #polygonCornerList do -- find the smallest x and y
		if (polygonCornerList[i][1] <= minX) then
			minX = polygonCornerList[i][1]
		end
		if (polygonCornerList[i][2] <= minY) then
			minY = polygonCornerList[i][2]
		end
	end
	minX = math.abs(minX)         -- should eventually calculate the difference between minX and 0
	minY = math.abs(minY)         -- should eventually calculate the difference between minY and 0

	for i = 1, #polygonCornerList do -- make it bounded to 0, 0
		polygonCornerList[i][1] = round(polygonCornerList[i][1] + minX)
		polygonCornerList[i][2] = round(polygonCornerList[i][2] + minY)
	end

	if not module:construct_polygon_from_list() then
		error("This error should never happen.")
	end
end

function module:circle_like_polygon_prism(numSides, diameter, height, offsetAngle)
	offsetAngle = offsetAngle or 0
	for i = 1, height do
		module:circle_like_polygon(numSides, diameter, offsetAngle)
		if i ~= height then
			self.track:to(self.track.location.x, self.track.location.y + 1, self.track.location.z, self.force)
		end
	end
end

function module:polygon_prism(numSides, sideLength, height, offsetAngle)
	offsetAngle = offsetAngle or 0
	for i = 1, height do
		module:polygon(numSides, sideLength, offsetAngle)
		if i ~= height then
			self.track:to(self.track.location.x, self.track.location.y + 1, self.track.location.z, self.force)
		end
	end
end

function module:hexagon(length) -- Deprecated, please use polygon(6, sideLength, 0). Fills out polygonCornerList with the points for a hexagon.
	module:polygon_prism(6, length, 0)
end

function module:octagon(length) -- Deprecated, please use polygon(8, sideLength, 0). Fills out polygonCornerList with the points for an octagon
	module:polygon_prism(8, length, 0)
end

function module:hexagon_prism(length, height) -- Deprecated, please use polygonPrism(6, sideLength, height, 0).
	module:polygon_prism(6, length, height, 0)
end

function module:octagon_prism(length, height) -- Deprecated, please use polygonPrism(8, sideLength, height, 0).
	module:polygon_prism(8, length, height, 0)
end

return module
