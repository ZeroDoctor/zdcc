
local track = require("../lib.track_move")

local script = {}

function script:init(move)
	self.track = move or track
end

function script:inspect()

end

function script:inspectUp()

end

function script:inspectDown()

end

local function add_block(self, data)
	local block = {
		location = self.track.location,
		data = data
	}
end

return script

