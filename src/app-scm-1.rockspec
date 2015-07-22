package = "app"
version = "scm-1"
source = {
  url = "",
  dir = "."
}
description = {
  summary = "",
  detailed = [[
  ]]
}
dependencies = {
  "lua >= 5.1",
  "busted >= 1.5.0",
  "router >= 2.1-0",
  "lua-resty-http >= 0.1-0",
}
build = {
  type = "builtin",
  modules = {
  },
  install = {
  }
}
