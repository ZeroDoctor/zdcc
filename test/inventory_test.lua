local turtle = require('test.turtle_test_api')
local textutils = require('test.textutils_test')

local check = require('../lib.check_inventory')
local log = require('../log.logs')

local function init(l)
	log = l or log
	check.log = log
	check:init()
end

local function test_searchname()
	check:update()
	local o = check:search_name({'.*minecraft.*'}, true)
	if o == nil then
		log:error('did not find name with minecraft [{}]', o)
	end
end

local function test_searchname_or()
	check:update()
	local o = check:search_name({'.*torch.*', '.*oak.*'}, true)
	if o == nil then
		log:error('did not find name with minecraft [{}]', o)
	end
end

local function test_searchtag()
	check:update()
	local o = check:search_tag('.*light.*')
	if o == nil then
		log:error('did not find tag with light [{}]', o)
	end
end

local function test_flatten()
	check:update()
	table.insert(turtle.inventory,
		{
			name = "minecraft:torch",
			tags = {["minecraft:light"] = true},
			count = 5,
			location = {11},
		}
	)
	check:update()

	if not check.inventory[1]["count"] == 32 then
		log:error('with [1] count\n\t want {} \n\t got {}',
			32, check.inventory[1]["count"])
	end
	if not check.inventory[1]["location"][1] == 1 then
		log:error('with [1] location\n\t want {} \n\t got {}',
			1, check.inventory[1]["location"][1])
	end
	if not check.inventory[1]["name"] == "minecraft:oak_log" then
		log:error('with [1] name\n\t want {} \n\t got {}',
			"minecraft:oak_log", check.inventory[1]["name"])
	end
	if not check.inventory[1]["tags"]["minecraft:logs"] == true then
		log:error('with [1] tags\n\t want {} \n\t got {}',
			true, check.inventory[1]["tags"]["minecraft:logs"])
	end

	if not check.inventory[11]["count"] == 4 then
		log:error('with [11] count\n\t want {} \n\t got {}',
			4, check.inventory[11]["count"])
	end
	if not check.inventory[11]["location"][1] == 11 then
		log:error('with [11] location\n\t want {} \n\t got {}',
			11, check.inventory[11]["location"][1])
	end
	if not check.inventory[11]["name"] == "minecraft:torch" then
		log:error('with [11] name\n\t want {} \n\t got {}',
			"minecraft:torch", check.inventory[1]["name"])
	end
	if not check.inventory[11]["tags"]["minecraft:light"] == true then
		log:error('with [11] tags\n\t want {} \n\t got {}',
			true, check.inventory[11]["tags"]["minecraft:light"])
	end

	if not check.inventory[5]["count"] == 4 then
		log:error('with [5] count\n\t want {} \n\t got {}',
			4, check.inventory[5]["count"])
	end
	if not check.inventory[5]["location"][1] == 5 then
		log:error('with [5] location\n\t want {} \n\t got {}',
			5, check.inventory[5]["location"][1])
	end
	if not check.inventory[5]["name"] == "minecraft:torch" then
		log:error('with [5] name\n\t want {} \n\t got {}',
			"minecraft:torch", check.inventory[5]["name"])
	end
	if not check.inventory[5]["tags"]["minecraft:light"] == true then
		log:error('with [5] count\n\t want {} \n\t got {}',
			true, check.inventory[5]["tags"]["minecraft:light"])
	end

	if not check.inventory[9]["count"] == 16 then
		log:error('with [9] count\n\t want {} \n\t got {}',
			16, check.inventory[9]["count"])
	end
	if not check.inventory[9]["location"][1] == 9 then
		log:error('with [9] location\n\t want {} \n\t got {}',
			9, check.inventory[9]["location"][1])
	end
	if not check.inventory[9]["name"] == "minecraft:cobblestone" then
		log:error('with [9] name\n\t want {} \n\t got {}',
			"minecraft:cobblestone", check.inventory[9]["name"])
	end
	if not check.inventory[9]["tags"]["minecraft:stone"] == true then
		log:error('with [9] tags\n\t want {} \n\t got {}',
			true, check.inventory[9]["tags"]["minecraft:stone"])
	end

	check:flatten()
	if not #check.map["minecraft:torch"].location == 1 then
		log:error('torch did not flatten to {} instead {}',
			1, #check.map["minecraft:torch"].location
		)
	end

	if not check.map["minecraft:torch"].count == 9 then
		log:error('torches did not merge count to {} instead {}',
			9, check.map["minecraft:torch"].count
		)
	end

	if not check.inventory[5] == nil then
		log:error('did not flatten, inventory with position 5 still exists')
	end
end

return {
	init            = init,
	test_searchname = test_searchname,
	test_searchname_or = test_searchname_or,
	test_searchtag  = test_searchtag,
	test_flatten    = test_flatten,
}

