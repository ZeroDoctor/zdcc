
local track = require("../lib.track_move")

local module = {}

function module:init(move)
	self.track = move or track
end

function module:inspect()

end

function module:inspectUp()

end

function module:inspectDown()

end

local function add_block(self, data)
	local block = {
		location = self.track.location,
		data = data
	}
end

return module

