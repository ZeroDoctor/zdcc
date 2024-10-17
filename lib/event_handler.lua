---@class event_handler
local module = {
	events = {}
}

---@return event_handler
function module:new()
	local class = setmetatable({}, self)
	self.__index = self
	return class
end

---@param event string
---@param handler fun(...)
function module:on(event, handler)
	if not self.events[event] then
		self.events[event] = {}
	end

	table.insert(self.events[event], handler)
end

---@param event string
---@param ... any
function module:trigger(event, ...)
	if not self.events[event] then
		return
	end

	for index, _ in ipairs(self.events[event]) do
		self.events[event][index](...)
	end
end

return module