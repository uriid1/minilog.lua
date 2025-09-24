--- Minilog library
--
local stdout = io.stdout
local stderr = io.stderr
local unpack = unpack or table.unpack

local colors = {
  red = '\27[38;5;9m',
  yellow = '\27[38;5;11m',
  green = '\27[38;5;10m',
  orange = '\27[38;5;214m'
}

local log = {
  disable_stdout = false,
  disable_stderr = false,
  output_file = nil,    -- nil to disable

  force_flush = false,
  date_format = '%X',   -- ex 20:10:11
  debug = true,         -- ex test.lua:1
  colors = colors
}

local type = {
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error'
}

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
  local info = debug.getinfo(3, 'Sl')
  return 
    colorize(colors.yellow,
    info.short_src..':'..info.currentline)..':'
end

local function writeLog(buffer, type)
  local fd = io.open(log.output_file, 'a')
  fd:write(os.date('[%x %X]: '), type, '>', table.concat(buffer))
  fd:close()
end

-- see: https://gist.github.com/uriid1/2b7823c096b3a697ceab7f40b4ccc54b
local function f(text, args)
  local res, _ = string.gsub(text, '%${([%w_]+)}', args)
  return res
end

function log.info(text, ctx)
  if log.disable_stdout and output_file == nil then
    return
  end

  local buffer = {}
  table.insert(buffer, ' ')
  table.insert(buffer, ctx and f(tostring(text), ctx) or tostring(text))
  table.insert(buffer, '\n')

  if log.output_file then
    writeLog(buffer, type.INFO)
  end

  if log.disable_stdout then
    return
  end

  local prefix = {}
  table.insert(prefix, os.date('['..log.date_format..'] '))
  table.insert(prefix, colorize(colors.green, '['..type.INFO..']'))
  if log.debug then
    table.insert(prefix, ' ')
    table.insert(prefix, _src_debug())
  end

  stdout:write(table.concat(prefix), table.concat(buffer))
  if log.force_flush then
    io.flush()
  end
end

function log.warn(text, ctx)
  if log.disable_stdout and output_file == nil then
    return
  end

  local buffer = {}
  table.insert(buffer, ' ')
  table.insert(buffer, ctx and f(tostring(text), ctx) or tostring(text))
  table.insert(buffer, '\n')

  if log.output_file then
    writeLog(buffer, type.WARN)
  end

  if log.disable_stdout then
    return
  end

  local prefix = {}
  table.insert(prefix, os.date('['..log.date_format..'] '))
  table.insert(prefix, colorize(colors.orange, '['..type.WARN..']'))
  if log.debug then
    table.insert(prefix, ' ')
    table.insert(prefix, _src_debug())
  end

  stdout:write(table.concat(prefix), table.concat(buffer))
  if log.force_flush then
    io.flush()
  end
end

function log.error(text, ctx)
  if log.disable_stderr and output_file == nil then
    return
  end

  local buffer = {}
  table.insert(buffer, ' ')
  table.insert(buffer, ctx and f(tostring(text), ctx) or tostring(text))
  table.insert(buffer, '\n')

  if log.output_file then
    writeLog(buffer, type.ERROR)
  end

  if log.disable_stderr then
    return
  end

  local prefix = {}
  table.insert(prefix, os.date('['..log.date_format..'] '))
  table.insert(prefix, colorize(colors.red, '['..type.ERROR..']'))
  if log.debug then
    table.insert(prefix, ' ')
    table.insert(prefix, _src_debug())
  end

  stdout:write(table.concat(prefix))
  io.flush()
  stderr:write(table.concat(buffer))
  
  if log.force_flush then
    io.flush()
  end
end

return log
