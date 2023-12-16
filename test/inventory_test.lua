local check = require('lib.check_inventory')
local textutils = require('test.textutils_test')

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

