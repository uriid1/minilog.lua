package = "minilog"
version = "1.0-0"
source = {
  url = "git+https://github.com/uriid1/minilog.lua.git",
}
description = {
  summary = "A tiny lua logger with fstring.",
  detailed = [[
    see: https://github.com/uriid1/minilog.lua/blob/main/test.lua
  ]],
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["minilog"] = "minilog.lua"
  }
}
