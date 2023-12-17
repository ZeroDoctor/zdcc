local log = require('log.logs')
local loop = require('test.loop_test')

log:init(0)

print('start')
log:debug('weird')
log:debug('eric, when did you eat spaghetti')
log:error('mean and scary')
log:info('hanging out down the street')
log:warn('the same old thing')
log:error('we did last week')
log:info('not a thing to do')
log:info('but talk to you')
log:warn('we all alright')
log:info('we all alright')
log:debug('hello wisconsin')
loop.test_logs()
print('end')

log:cleanup()

