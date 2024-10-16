local stack = {}

stack.__index = stack

function stack.new()
	local self = setmetatable({}, stack)
	self._stack = {}
	return self
end

-- Check if the stack is empty
function stack:is_empty()
	return #self._stack == 0
end

-- Put a new value onto the stack
function stack:push(value)
	table.insert(self._stack, value)
end

-- Take a value off the stack
function stack:pop()
	if self:is_empty() then
		return nil
	end

	return table.remove(self._stack, #self._stack)
end

return stack
