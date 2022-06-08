
local script = {
	current_slot = 1,
	inventory = {},
}

function script.init(self, config)
	self.current_slot = config.current_slot or 1
	self.inventory = config.inventory or {}
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

function script.getFuelLevel() end
function script.getFuelLimit() end
function script.refuel(count) end

function script.compareTo(slot) end
function script.transferTo(slot, count) return true end

function script.select(slot)
	script.current_slot = slot
end
function script.getItemCount(slot)
	slot = slot or script.current_slot
	return script.inventory[slot] or 0
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

	if slot ~= 1 then return nil end
	return {
		name = "minecraft:oak_log",
		count = 11,
	}
end

function script.inspect()
	return true, {
		name = "minecraft:oak_log",
		state = { axis = "x" },
		tags = {["minecraft:logs"] = true},
	}
end
function script.inspectUp()
	return true, {
		name = "minecraft:oak_log",
		state = { axis = "x" },
		tags = {["minecraft:logs"] = true},
	}
end
function script.inspectDown()
	return true, {
		name = "minecraft:oak_log",
		state = { axis = "x" },
		tags = {["minecraft:logs"] = true},
	}
end

return script

