-- #test
local turtle = require("test.turtle_test_api")
-- #end

local log = require("../log.logs")

local module = {
	map = {},
	track = require("../lib.track_move")
}

function module:new(track)
	local class = setmetatable({}, self)
	self.__index = self

	self.track = track or self.track

	return class
end

function module:set_log(p_log) log = p_log end

function module:inspect()
	local has_block, data = turtle.inspect()
	if has_block then
		self:add_block(data)
	end
end

function module:inspectUp()
	local has_block, data = turtle.inspectUp()
	if has_block then
		self:add_block(data)
	end
end

function module:inspectDown()
	local has_block, data = turtle.inspectDown()
	if has_block then
		self:add_block(data)
	end
end

function module:add_block(data)
	local x = self.track.location.x
	local y = self.track.location.y
	local z = self.track.location.z

	self.map[x][y] = {}
	self.map[x][y][z] = data
end

function module:get_block(x, y, z)
	if not self.map[x] then
		return nil
	end

	if not self.map[x][y] then
		return nil
	end

	if not self.map[x][y][z] then
		return nil
	end

	return self.map[x][y][z]
end

return module

