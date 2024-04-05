local move_test = require("test.move_test")
local log = require('./log.logs')
log:init(0)

log:info('---- testing ----')
move_test.movement_test()
move_test.retrace_test()
move_test.to_test()

