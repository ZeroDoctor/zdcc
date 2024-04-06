local move_test = require("test.move_test")
local log = require('./log.logs')
log:init(0)

log:info('---- start move testing ----')

log:info('---- movement test ----')
move_test.movement_test()

log:info('---- retrace test ----')
move_test.retrace_test()

log:info('---- to test ----')
move_test.to_test()

log:info('---- end move testing ----')

