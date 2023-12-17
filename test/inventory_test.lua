local check = require('lib.check_inventory')
local turtle = require('test.turtle_test_api')
local textutils = require('test.textutils_test')
local log = require('log.logs')

local function test_searchname()
	local o = check:search_name('.*minecraft.*', true)
	print(textutils.serialise(o))
end

local function test_searchtag()
	local o = check:search_tag('.*light.*')
	print(textutils.serialise(o))
end

check:update()

test_searchname()
test_searchtag()

log:debug('before inv={}', turtle.inventory)
table.insert(turtle.inventory,
	{
		name = "minecraft:torch",
		tags = {["minecraft:light"] = true},
		count = 4,
		location = {11},
	}
)
check:update()
log:debug('after inv={}', turtle.inventory)
log:debug('********* inv={}', check.inventory)

print()
print()
print('-------------')
print()
print()

check:flatten()

