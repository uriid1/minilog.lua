local log = require('minilog')

log.output_file = 'program.log'

log.info('An info message')
log.info('Age: ${age}, Name: ${name}', { age = 25, name = 'Gordon' })

local value = 12.100101
log.warn('An warn message ')
log.warn('A potential possible problem | Value: ${value}', { value = value })

log.verbose('Server start: %s | PORT: %d', '0.0.0.0', 8080)

log.error('An error message')
log.error('Program will crash | Initiator: ${initiator}', { initiator = 'you :>' })
