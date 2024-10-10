local log = require('log.logs')
log:init(0)

local move_test = require("test.move_test")
local inv_test = require("test.inventory_test")

move_test.init(log)
inv_test.init(log)

------------------

log:info('---- start move testing ----')

log:info('---- movement test')
move_test.movement_test()

log:info('---- retrace test')
move_test.retrace_test()

log:info('---- to test')
move_test.to_test()

log:info('---- end move testing ----')

------------------

log:info('---- start inventory testing ----')

log:info('---- search name test')
inv_test.test_searchname()

log:info('---- search name or test')
inv_test.test_searchname_or()

log:info('---- search tag test')
inv_test.test_searchtag()

log:info('---- search flatten test')
inv_test.test_flatten()

log:info('---- end inventory testing ----')

------------------


