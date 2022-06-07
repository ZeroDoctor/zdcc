
-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
-- remember to comment out above before use

-- place/patch = {
-- 	{
-- 		tags = {"torch", "lever"},
-- 		where = ensure.left(),
-- 		location = 12,
-- 	},
-- }

local script = {
	patch = {}, -- occurs when no blocks exists
	place = {}, -- occurs when blocks already exist
	track = require('track_move'),
	careful = require('careful_dig'),
}

function script:init(config, track, careful)
	self.patch = config.patch or {}
	self.place = config.place or {}

	if track ~= nil then
		self.track = track
	end

	if careful ~= nil then
		self.careful = careful
	end
end

function script:auto()
end

function script:place(text, config)
	if config == nil then
		return turtle.place(text)
	end

end

function script:placeUp(text, config)
	if config == nil then
		return turtle.placeUp(text)
	end

end

function script:placeDown(text, config)
	if config == nil then
		return turtle.placeDown(text)
	end

end

function script:front() return 0 end
function script:right() return 1 end
function script:back() return 2 end
function script:left() return 3 end
function script:top() return 4 end
function script:bottom() return 5 end

return script

