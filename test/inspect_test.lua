local turtle = require('test.turtle_test_api')

local track = require('../lib.track_move')
local map = require('../lib.map_inspect')
local log = require('../log.logs')

local function init(l)
    track = track:new()
	map = map:new(track)
	map:set_log(l)
	log = l

    turtle:init({})
end


local function test_getblock()
    log:trace("{}", map:get_block(5, 5, 5))
end


return {
    init = init,
    test_getblock = test_getblock
}
