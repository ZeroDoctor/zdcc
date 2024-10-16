
local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

---@param t1 any|table First object to compare
---@param t2 any|table Second object to compare
---@param ignore_mt boolean True to ignore metatables (a recursive function to tests tables inside tables)
local function equals(t1, t2, ignore_mt)
    if t1 == t2 then return true end
    local o1Type = type(t1)
    local o2Type = type(t2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(t1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return t1 == t2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(t1) do
        local value2 = t2[key1]
        if value2 == nil or equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(t2) do
        if not keySet[key2] then return false end
    end
    return true
end

local function contains(t1, elem, ignore_mt)
  local ignore = ignore_mt or true

  for index, _ in ipairs(t1) do
    if equals(t1[index], elem, ignore) then
      return true
    end
  end

  return false
end

local function find_element_index(t1, elem)
  for index, _ in ipairs(t1) do
    if equals(t1[index], elem, true) then
      return index
    end
  end

  return -1
end


return {
	copy = copy,
  equals = equals,
  contains = contains,
  find_element_index = find_element_index
}
