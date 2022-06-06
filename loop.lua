
-- remember to comment out below before use
local turtle = require("test.turtle_test_api")
-- remember to comment out above before use

local track = require("track_pos")

local script = {
	init = function(self) end,
	update = function(self, track)
		return false
	end,
}

function script:start(config)
	-- sane defaults
	config.avoid = config.avoid or {}
	config.patch = config.patch or {}
	config.refuel = config.refuel or true
	config.retrace_feel = config.retrace_feel or false

	config.move_limit = turtle.getFuelLevel() / 2
	if config.refuel then
		track.limit = config.move_limit
	end

	script:init()

  local running = true
	while running do
		running = script:update(track)

		if track.should_goback then
			track:retrace(config.retrace_feel)
		end

	end
end


return script

