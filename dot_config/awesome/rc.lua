-- awesome_mode: api-level=4:screen=on
pcall(require, "luarocks.loader")

local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")

beautiful.init(gears.filesystem.get_configuration_dir() .. "config/colors.lua")

require("bindings")
require("rules")
require("signals")

awful.spawn.with_shell("~/.config/awesome/scripts/autorun")
