--- Minilog library
--
local stdout = io.stdout
local stderr = io.stderr
local unpack = unpack or table.unpack

local colors = {
  GREEN = '\27[38;5;10m',
  BLUE = '\27[38;5;12m',
  ORANGE = '\27[38;5;214m',
  RED = '\27[38;5;9m',
  YELLOW = '\27[38;5;11m',
}

local log_type = {
  INFO = 'info',
  VERBOSE = 'verbose',
  WARN = 'warn',
  ERROR = 'error'
}

local color_by_type = {
  [log_type.INFO] = colors.GREEN,
  [log_type.VERBOSE] = colors.BLUE,
  [log_type.WARN] = colors.ORANGE,
  [log_type.ERROR] = colors.RED
}

local writer_by_logtype = {
  [log_type.INFO] = stdout,
  [log_type.VERBOSE] = stdout,
  [log_type.WARN] = stdout,
  [log_type.ERROR] = stderr
}

local log = {
  debug_level = 3,
  disable_stdout = false,
  disable_stderr = false,
  output_file = nil,    -- nil to disable

  force_flush = false,
  date_format = '%X',   -- ex 20:10:11
  debug = true,         -- ex test.lua:1
  colors = colors
}

-- TODO:
log.cfg = function(cfg)

end

local use_color = (function()
  local term = os.getenv('TERM')

  if term and (term == 'xterm' or term:find'-256color$') then
    return true
  else
    return false
  end
end)()

local function colorize(color, text)
  if use_color == false then
    return text
  end

  return color..text..'\27[0m'
end

local function _src_debug()
  local info = debug.getinfo(log.debug_level + 1, 'Sl')
  return
    colorize(colors.YELLOW,
    info.short_src..':'..info.currentline)..':'
end

local function writeLog(buffer, _log_type)
  local fd = io.open(log.output_file, 'a')

  if fd == nil or io.type(fd) ~= 'file' then
    error('unable to open file: ' .. log.output_file, 3)
  end

  fd:write(os.date('[%x %X]: '), _log_type, '>', table.concat(buffer))
  fd:close()
end

local function f(text, ...)
  if select('#', ...) == 1 and type(select(1, ...)) == 'table' then
    local res, _ = string.gsub(text, '%${([%w_]+)}', select(1, ...))
    return res
  end

  return text:format(...)
end

local function say(_log_type, text, ...)
  if log.disable_stdout and log.output_file == nil then
    return
  end

  local buffer = {}
  table.insert(buffer, ' ')
  table.insert(buffer, ... and f(tostring(text), ...) or tostring(text))
  table.insert(buffer, '\n')

  if log.output_file then
    writeLog(buffer, _log_type)
  end

  if log.disable_stdout then
    return
  end

  local prefix = {}
  table.insert(prefix, os.date('['..log.date_format..'] '))
  table.insert(prefix, colorize(color_by_type[_log_type], '['.._log_type..']'))

  if log.debug then
    table.insert(prefix, ' ')
    table.insert(prefix, _src_debug())
  end

  writer_by_logtype[_log_type]:write(table.concat(prefix), table.concat(buffer))

  if log.force_flush then
    io.flush()
  end
end

function log.info(text, ...)
  say(log_type.INFO, text, ...)
end

function log.verbose(text, ...)
  say(log_type.VERBOSE, text, ...)
end

function log.warn(text, ...)
  say(log_type.WARN, text, ...)
end

function log.error(text, ...)
  say(log_type.ERROR, text, ...)
end

return log
