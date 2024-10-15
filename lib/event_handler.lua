local module = {}

function module:new()
	local class = setmetatable({}, self)
	self.__index = self
	return class
end


return module