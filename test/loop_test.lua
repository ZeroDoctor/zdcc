local log = require('log.logs')

local function test_logs()
	log:warn('michel!')
end

return {
	test_logs = test_logs
}
