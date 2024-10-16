local turtle = require('test.turtle_test_api')

local track = require('../lib.track_move')
local map = require('../lib.map_inspect')
local log = require('../log.logs')

local function init(p_log)
    track = track:new()
	map = map:new(track)
	map:set_log(p_log)
	log = p_log

    turtle:init({log = p_log})
end


local function test_getblock()
    log:debug("{}", map:find_block('minecraft:dirt'))
    track:to(5, 5, 5, 1)
    map:inspect()
    log:debug("{}", map:find_block('minecraft:dirt'))
end


return {
    init = init,
    test_getblock = test_getblock
}
