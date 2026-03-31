local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")

require("awful.autofocus")

client.connect_signal("mouse::enter", function(c)
	c:activate({ context = "mouse_enter", raise = false })
end)

client.connect_signal("manage", function(c)
	c.shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, beautiful.border_radius)
	end
end)

client.connect_signal("request::titlebars", function(c)
	local buttons = {
		awful.button({
			modifiers = {},
			button = 1,
			on_press = function()
				c:activate({ context = "titlebar", action = "mouse_move" })
			end,
		}),
		awful.button({
			modifiers = {},
			button = 3,
			on_press = function()
				c:activate({ context = "titlebar", action = "mouse_resize" })
			end,
		}),
	}

	awful.titlebar(c).widget = {
		{
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},

		{

			{
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},

		{
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	}
end)
