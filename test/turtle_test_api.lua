local tbl = require('../util.tbl')
local log = require('../log.logs')

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

local module = {
	current_slot = 1,
	inventory = inventory or {},
	world = {},
	turtle_location = {},
	turtle_direction = front_face,
}

function module.init(self, config)
	self.current_slot = config.current_slot or 1
	self.inventory = config.inventory or inventory
	log = config.log or log

	log:debug('[world] creating new world...')
	local current_block = tbl.copy(blocks[3]) -- stone
	local max_size = 50

	for x = 1, max_size, 1 do
		self.world[x] = {}
		for y = 1, max_size, 1 do
			self.world[x][y] = {}

			if y > max_size/2 and y <= max_size/2.33 then
				current_block = tbl.copy(blocks[1]) -- air
			elseif y > max_size/2.33 then
				current_block = tbl.copy(blocks[2]) -- dirt
			end

			for z = 1, max_size, 1 do
				local b = tbl.copy(current_block)
				b.vec = {x = x, y = y, z = z}
				self.world[x][y][z] = b
			end
		end
	end

	self.turtle_location = {x = 1, y = math.floor(max_size/(2.32)), z = 1}
end

function module.dig(side) return true end
function module.digUp(side) return true end
function module.digDown(side) return true end

function module.detect() return false end
function module.detectUp() return false end
function module.detectDown() return false end

function module.forward() return true, nil end
function module.back() return true, nil end
function module.up() return true, nil end
function module.down() return true, nil end
function module.turnLeft() return true, nil end
function module.turnRight() return true, nil end

function module.place(text) end
function module.placeUp(text) end
function module.placeDown(text) end

function module.drop(count) end
function module.dropUp(count) end
function module.dropDown(count) end

function module.compare() end
function module.compareUp() end
function module.compareDown() end

function module.attack(side) end
function module.attackUp(side) end
function module.attackDown(side) end

function module.suck(count) end
function module.suckUp(count) end
function module.suckDown(count) end

function module.getFuelLevel() return 80 end
function module.getFuelLimit() end
function module.refuel(count) end

function module.compareTo(slot) end
function module.transferTo(slot, count)
	local selected_item = module.getItemDetail(module.current_slot)
	local slot_item = module.getItemDetail(slot)

	if not selected_item then
		log:error('[transferTo] no item at selection {}', module.current_slot)
		return false
	end

	count = count or selected_item.count
	if slot_item then
		if slot_item.name ~= selected_item.name then
			log:error('[transferTo] can not merge unique items {} and {}',
				slot_item.name, selected_item.name
			)
			return false
		end

		slot_item.count = slot_item.count + count
		module.inventory[slot_item.index] = slot_item

	else
		local tmp = tbl.copy(module.inventory[module.current_slot])
		table.insert(module.inventory, tmp)
	end

	table.remove(module.inventory, selected_item.index)
	return true
end

function module.select(slot)
	module.current_slot = slot
end

function module.getItemCount(slot)
	slot = slot or module.current_slot

	for _, inv in ipairs(module.inventory) do
		for _, loc in ipairs(inv.location) do
			if loc == slot then
				return inv.count
			end
		end
	end

	return 0
end

function module.getItemSpace(slot)
	slot = slot or module.current_slot
	if slot ~= 1 then return 64 end
	return 53
end

function module.getSelectedSlot()
	return 1
end

function module.getItemDetail(slot, detail)
	detail = detail or false

	for i, v in ipairs(module.inventory) do
		for _, value in ipairs(v.location) do
			if value == slot then
				v.index = i
				return v
			end
		end
	end

	return nil
end

function module.inspect()
	local x_dir = 1
	local z_dir = 0

	if module.turtle_direction == right_face
		or module.turtle_direction == left_face then

		x_dir = 0
		z_dir = 1
	end

	local x = module.turtle_location.x
	local y = module.turtle_location.y
	local z = module.turtle_location.z

	local b = module.world[x+x_dir][y][z+z_dir]
	if b == nil or b.solid == nil then
		b = blocks[1]
	end

	return b.solid, b
end

function module.inspectUp()
	local x = module.turtle_location.x
	local y = module.turtle_location.y
	local z = module.turtle_location.z

	local b = module.world[x][y+1][z]
	if b == nil or b.solid == nil then
		b = blocks[1]
	end


	return b.solid, b
end
function module.inspectDown()
	local x = module.turtle_location.x
	local y = module.turtle_location.y
	local z = module.turtle_location.z

	local b = module.world[x][y-1][z]
	if b == nil or b.solid == nil then
		b = blocks[1]
	end


	return b.solid, b
end

return module

