-- #test
local turtle = require("test.turtle_test_api")
-- #end

local log = require('../log.logs')

local script = {
	must_empty = true,
	avoid = {},
}

function script:dig(side)
	if not self.must_empty then
		if turtle.detect() then
			return turtle.dig(side)
		end

		return true
	end

	local running = true
	while running do
		if not turtle.detect() then -- in the case that avoid array is empty
			return true
		end

		if not self:is_okay(turtle.inspect) then
			return false
		end

		turtle.dig(side)
	end
end

function script:digUp(side)
	if not self.must_empty then
		if turtle.detectUp() then
			return turtle.digUp(side)
		end

		return true
	end

	local running = true
	while running do
		if not turtle.detectUp() then
			return true
		end

		if not self:is_okay(turtle.inspectUp) then
			return false
		end

		turtle.digUp(side)
	end
end

function script:digDown(side)
	if not self.must_empty then
		if turtle.detectDown() then
			return turtle.digDown(side)
		end

		return true
	end

	local running = true
	while running do
		if not turtle.detectDown() then
			return true
		end

		if not self:is_okay(turtle.inspectDown) then
			return false
		end

		turtle.digDown(side)
	end
end

function script:is_okay(inspect)
	for _, value in ipairs(self.avoid) do -- iterate through blocks to avoid
		local found, block = inspect()
		if found then
			if string.find(block.name, value) then
				log:info('{dig} found block with [name={}]. avoiding...', block.name)
				return false
			end

			for key in pairs(block.tags) do -- iterate through current block tags
				local result = string.find(key, value)
				if result ~= nil then
					log:info('{dig} found block with [tag={}]. avoiding...', key)
					return false
				end
			end
		end
	end

	return true
end

return script

