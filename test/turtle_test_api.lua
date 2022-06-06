
return { -- used for testing purposes
	dig = function(side) return true end,
	digUp = function(side) return true end,
	digDown = function(side) return true end,

	detect = function() return true end,
	detectUp = function() return true end,
	detectDown = function() return true end,

	forward = function() return true, nil end,
	back = function() return true, nil end,
	up = function() return true, nil end,
	down = function() return true, nil end,
	turnLeft = function() return true, nil end,
	turnRight = function() return true, nil end,

	place = function(text) end,
	placeUp = function(text) end,
	placeDown = function(text) end,

	drop = function(count) end,
	dropUp = function(count) end,
	dropDown = function(count) end,

	select = function(slot) end,
	getItemCount = function(slot) end,
	getItemSpace = function(slot) end,
	
	compare = function () end,
	compareUp = function () end,
	compareDown = function () end,

	attack = function(side) end,
	attackUp = function(side) end,
	attackDown = function(side) end,
	
	suck = function(count) end,
	suckUp = function(count) end,
	suckDown = function(count) end,

	getFuelLevel = function() end,
	getFuelLimit = function() end,
	refuel = function(count) end,

	compareTo = function(slot) end,
	transferTo = function(slot, count) end,

	getSelectedSlot = function() end,

	inspect = function() end,
	inspectUp = function() end,
	inspectDown = function() end,
}

