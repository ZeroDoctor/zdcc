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
		for _, value in ipairs(self.avoid) do -- iterate through blocks to avoid
			local found_block, block_meta = turtle.inspect()
			if found_block then
				for key in pairs(block_meta.tags) do -- iterate through current block tags
					local result = string.find(key, value)
					if result ~= nil then
						return false, "found block with tag "..key -- return false if block is found
					end
				end
			end
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
		for _, value in ipairs(self.avoid) do -- iterate through blocks to avoid
			local found_block, block_meta = turtle.inspectUp()
			if found_block then
				for key in pairs(block_meta.tags) do -- iterate through current block tags
					local result = string.find(key, value)
					if result ~= nil then
						return false, "found block with tag "..key -- return false if block is found
					end
				end
			end
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
		for _, value in ipairs(self.avoid) do -- iterate through blocks to avoid
			local found_block, block_meta = turtle.inspectDown()
			if found_block then
				for key in pairs(block_meta.tags) do -- iterate through current block tags
					local result = string.find(key, value)
					if result ~= nil then
						return false, "found block with tag "..key -- return false if block is found
					end
				end
			end
		end

		if not turtle.detectDown() then
			return true, nil
		end

		turtle.digDown(side)
	end
end

return script

