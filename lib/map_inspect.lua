-- #test
local turtle = require("test.turtle_test_api")
-- #end

local tbl = require("../util.tbl")
local log = require("../log.logs")

local module = {
	---@alias block_data
	---| {name: string, tags: table, vec: table, solid: boolean}
	---@alias location {x: integer, y: integer, z: integer}
	---@alias block {x: integer, y: integer, z: integer, data: block_data}

	---@type block[][][]
	map = {},
	---@type table<string, location[]>
	blocks = {},
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

function module:inspect_up()
	local has_block, data = turtle.inspectUp()
	if has_block then
		self:add_block(data)
	end
end

function module:inspect_down()
	local has_block, data = turtle.inspectDown()
	if has_block then
		self:add_block(data)
	end
end

---@param block_data block_data
function module:add_block(block_data)
	local x = self.track.location.x
	local y = self.track.location.y
	local z = self.track.location.z

	self.map[x] = {}
	self.map[x][y] = {}
	self.map[x][y][z] = { x = x, y = y, z = z, data = block_data }
	if not self.blocks[block_data.name] then
		self.blocks[block_data.name] = {}
	end
	table.insert(self.blocks[block_data.name], { x = x, y = y, z = z })
end

---@param name string
---@return block[]|nil
function module:find_block(name)
	if not self.blocks[name] then
		return nil
	end

	local list = {}

	local indices = self.blocks[name]
	for _, index in ipairs(indices) do
		table.insert(list, self.map[index.x][index.y][index.z])
	end

	log:trace("found [blocks={}] with [name={}]", list, name)
	return list
end

---@param x integer
---@param y integer
---@param z integer
---@return block|nil
function module:remove_block(x, y, z)
	if not self.map[x] then
		return nil
	elseif not self.map[x][y] then
		return nil
	elseif not self.map[x][y][z] then
		return nil
	end

	local block = tbl.copy(self.map[x][y][z])
	if not self.blocks[block.data.name] then
		return block
	end

	local index = tbl.find_element_index(self.blocks[block.data.name], { x = x, y = y, z = z })
	if index ~= -1 then
		table.remove(self.blocks[block.data.name], index)
	end

	if #self.blocks[block.data.name] then
		self.blocks[block.data.name] = nil
	end

	self.map[x][y][z] = nil
	return block
end

return module
