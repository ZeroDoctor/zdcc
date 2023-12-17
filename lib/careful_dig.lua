-- #test
local turtle = require("test.turtle_test_api")
-- #end

local script = {
	must_empty = true,
	avoid = {},
}

function script:dig(side)
	if not self.must_empty then
		if turtle.detect() then
			return turtle.dig(side)
		end

		return true, nil
	end

	local running = true
	while running do
		local ok, err = self:is_okay(turtle.inspect)
		if not ok then
			return ok, err
		end

		if not turtle.detect() then -- in the case that avoid array is empty
			return true, nil
		end

		turtle.dig(side)
	end
end

function script:digUp(side)
	if not self.must_empty then
		if turtle.detectUp() then
			return turtle.digUp(side)
		end

		return true, nil
	end

	local running = true
	while running do
		local ok, err = self:is_okay(turtle.inspectUp)
		if not ok then
			return ok, err
		end

		if not turtle.detectUp() then
			return true, nil
		end

		turtle.digUp(side)
	end
end

function script:digDown(side)
	if not self.must_empty then
		if turtle.detectDown() then
			return turtle.digDown(side)
		end

		return true, nil
	end

	local running = true
	while running do
		local ok, err = self:is_okay(turtle.inspectDown)
		if not ok then
			return ok, err
		end

		if not turtle.detectDown() then
			return true, nil
		end

		turtle.digDown(side)
	end
end


function script:is_okay(inspect)
	for _, value in ipairs(self.avoid) do -- iterate through blocks to avoid
		local found, block = inspect()
		if found then
			if string.find(block.name, value) then
				return false, "found block with name "..block.name
			end

			for key in pairs(block.tags) do -- iterate through current block tags
				local result = string.find(key, value)
				if result ~= nil then
					return false, "found block with tag "..key -- return false if block is found
				end
			end
		end
	end

	return true
end

return script

