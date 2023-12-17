
local log = require('log.logs')

local blocks = {
	{
		name = 'minecraft:air',
		tags = {['minecraft:void'] = true},
		vec = {},
		solid = false,
	},
	{
		name = 'minecraft:dirt',
		tags = {['minecraft:dirt'] = true},
		vec = {},
		solid = true,
	},
	{
		name = 'minecraft:stone',
		tags = {['minecraft:stone'] = true},
		vec = {},
		solid = true,
	},
	{
		name = 'minecraft:oak_log',
		tags = {['minecraft:logs'] = true},
		vec = {},
		solid = true,
	},
}

local inventory = {
	{
		name = "minecraft:oak_log",
		tags = {["minecraft:logs"] = true},
		count = 32,
		location = {1},
	},
	{
		name = "minecraft:cobblestone",
		tags = {["minecraft:stone"] = true},
		count = 16,
		location = {9},
	},
	{
		name = "minecraft:torch",
		tags = {["minecraft:light"] = true},
		count = 4,
		location = {5},
	},
}

local front_face = 0
local right_face = 1
local back_face =  2
local left_face =  3

local script = {
	current_slot = 1,
	inventory = inventory or {},
	world = {},
	turtle_location = {},
	turtle_direction = front_face,
}

function script.init(self, config)
	self.current_slot = config.current_slot or 1
	self.inventory = config.inventory or {}

	local current_block = blocks[3] -- stone
	local max_size = 500

	for x = 1, max_size, 1 do
		self.world[x] = {}
		for y = 1, max_size, 1 do
			self.world[x][y] = {}

			if y > max_size/2 then
				current_block = blocks[1] -- air
			elseif y > max_size/2.33 then
				current_block = blocks[2] -- dirt
			end

			for z = 1, max_size, 1 do
				local b = current_block
				b.vec = {x = x, y = y, z = z}
				self.world[x][y][z] = b
			end
		end
	end

	self.turtle_location = {0, max_size/2+1, 0}
end

function script.dig(side) return true end
function script.digUp(side) return true end
function script.digDown(side) return true end

function script.detect() return false end
function script.detectUp() return false end
function script.detectDown() return false end

function script.forward() return true, nil end
function script.back() return true, nil end
function script.up() return true, nil end
function script.down() return true, nil end
function script.turnLeft() return true, nil end
function script.turnRight() return true, nil end

function script.place(text) end
function script.placeUp(text) end
function script.placeDown(text) end

function script.drop(count) end
function script.dropUp(count) end
function script.dropDown(count) end

function script.compare() end
function script.compareUp() end
function script.compareDown() end

function script.attack(side) end
function script.attackUp(side) end
function script.attackDown(side) end

function script.suck(count) end
function script.suckUp(count) end
function script.suckDown(count) end

function script.getFuelLevel() return 80 end
function script.getFuelLimit() end
function script.refuel(count) end

function script.compareTo(slot) end
function script.transferTo(slot, count) return true end

function script.select(slot)
	script.current_slot = slot
end

function script.getItemCount(slot)
	slot = slot or script.current_slot

	for _, inv in ipairs(script.inventory) do
		for _, loc in ipairs(inv.location) do
			if loc == slot then
				return inv.count
			end
		end
	end

	return 0
end

function script.getItemSpace(slot)
	slot = slot or script.current_slot
	if slot ~= 1 then return 64 end
	return 53
end

function script.getSelectedSlot()
	return 1
end

function script.getItemDetail(slot, detail)
	detail = detail or false

	for _, v in ipairs(script.inventory) do
		for _, value in ipairs(v.location) do
			if value == slot then
				return v
			end
		end
	end

	return nil
end

function script.inspect()
	local x_dir = 1
	local z_dir = 0

	if script.turtle_direction == right_face
		or script.turtle_direction == left_face then

		x_dir = 0
		z_dir = 1
	end

	local x = script.turtle_location.x
	local y = script.turtle_location.y
	local z = script.turtle_location.z

	local b = script.world[x+x_dir][y][z+z_dir]
	if b == nil or b.solid == nil then
		b = blocks[1]
	end

	return b.solid, b
end

function script.inspectUp()
	local x = script.turtle_location.x
	local y = script.turtle_location.y
	local z = script.turtle_location.z

	local b = script.world[x][y+1][z]
	if b == nil or b.solid == nil then
		b = blocks[1]
	end


	return b.solid, b
end
function script.inspectDown()
	local x = script.turtle_location.x
	local y = script.turtle_location.y
	local z = script.turtle_location.z

	local b = script.world[x][y-1][z]
	if b == nil or b.solid == nil then
		b = blocks[1]
	end


	return b.solid, b
end

return script

