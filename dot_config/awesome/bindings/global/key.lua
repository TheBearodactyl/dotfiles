local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

require("awful.hotkeys_popup.keys")

local apps = require("config.apps")
local mod = require("bindings.mod")
local widgets = require("widgets")
local applauncher = require("widgets.applauncher")

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { mod.super },
		key = "s",
		description = "show help",
		group = "awesome",
		on_press = hotkeys_popup.show_help,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "w",
		description = "show main menu",
		group = "awesome",
		on_press = function()
			widgets.mainmenu:show()
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "r",
		description = "reload awesome",
		group = "awesome",
		on_press = awesome.restart,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "q",
		description = "quit awesome",
		group = "awesome",
		on_press = awesome.quit,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "x",
		description = "lua execute prompt",
		group = "awesome",
		on_press = function()
			awful.prompt.run({
				prompt = "Run Lua code: ",
				textbox = awful.screen.focused().promptbox.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval",
			})
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "Return",
		description = "open a terminal",
		group = "launcher",
		on_press = function()
			awful.spawn(apps.terminal)
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "r",
		description = "run prompt",
		group = "launcher",
		on_press = function()
			awful.screen.focused().promptbox:run()
		end,
	}),

	awful.key({
		modifiers = { mod.super },
		key = "p",
		description = "show app launcher",
		group = "launcher",
		on_press = function()
			applauncher.toggle()
		end,
	}),
})

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { mod.super },
		key = "Left",
		description = "view previous",
		group = "tag",
		on_press = awful.tag.viewprev,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "Right",
		description = "view next",
		group = "tag",
		on_press = awful.tag.viewnext,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "Escape",
		description = "go back",
		group = "tag",
		on_press = awful.tag.history.restore,
	}),
})

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { mod.super },
		key = "j",
		description = "focus next by index",
		group = "client",
		on_press = function()
			awful.client.focus.byidx(1)
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "k",
		description = "focus previous by index",
		group = "client",
		on_press = function()
			awful.client.focus.byidx(-1)
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "Tab",
		description = "go back",
		group = "client",
		on_press = function()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "j",
		description = "focus the next screen",
		group = "screen",
		on_press = function()
			awful.screen.focus_relative(1)
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "k",
		description = "focus the previous screen",
		group = "screen",
		on_press = function()
			awful.screen.focus_relative(-1)
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "n",
		description = "restore minimized",
		group = "client",
		on_press = function()
			local c = awful.client.restore()
			if c then
				c:activate({ raise = true, context = "key.unminimize" })
			end
		end,
	}),
})

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "j",
		description = "swap with next client by index",
		group = "client",
		on_press = function()
			awful.client.swap.byidx(1)
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "k",
		description = "swap with previous client by index",
		group = "client",
		on_press = function()
			awful.client.swap.byidx(-1)
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "u",
		description = "jump to urgent client",
		group = "client",
		on_press = awful.client.urgent.jumpto,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "l",
		description = "increase master width factor",
		group = "layout",
		on_press = function()
			awful.tag.incmwfact(0.05)
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "h",
		description = "decrease master width factor",
		group = "layout",
		on_press = function()
			awful.tag.incmwfact(-0.05)
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "h",
		description = "increase the number of master clients",
		group = "layout",
		on_press = function()
			awful.tag.incnmaster(1, nil, true)
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "l",
		description = "decrease the number of master clients",
		group = "layout",
		on_press = function()
			awful.tag.incnmaster(-1, nil, true)
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "h",
		description = "increase the number of columns",
		group = "layout",
		on_press = function()
			awful.tag.incncol(1, nil, true)
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "l",
		description = "decrease the number of columns",
		group = "layout",
		on_press = function()
			awful.tag.incncol(-1, nil, true)
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "space",
		description = "select next layout",
		group = "layout",
		on_press = function()
			awful.layout.inc(1)
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "space",
		description = "select previous layout",
		group = "layout",
		on_press = function()
			awful.layout.inc(-1)
		end,
	}),
})

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { mod.super },
		keygroup = "numrow",
		description = "only view tag",
		group = "tag",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		keygroup = "numrow",
		description = "toggle tag",
		group = "tag",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		keygroup = "numrow",
		description = "move focused client to tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl, mod.shift },
		keygroup = "numrow",
		description = "toggle focused client on tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		keygroup = "numpad",
		description = "select layout directly",
		group = "layout",
		on_press = function(index)
			local tag = awful.screen.focused().selected_tag
			if tag then
				tag.layout = tag.layouts[index] or tag.layout
			end
		end,
	}),
})

local function set_layout_by_name(name)
	local tag = awful.screen.focused().selected_tag
	if not tag then
		return
	end
	for _, l in ipairs(tag.layouts) do
		if l.name == name then
			tag.layout = l
			return
		end
	end
end

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { mod.super, mod.alt },
		key = "f",
		description = "set layout: floating",
		group = "layout",
		on_press = function()
			set_layout_by_name("floating")
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.alt },
		key = "t",
		description = "set layout: tile",
		group = "layout",
		on_press = function()
			set_layout_by_name("tile")
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.alt },
		key = "y",
		description = "set layout: tile.left",
		group = "layout",
		on_press = function()
			set_layout_by_name("tileleft")
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.alt },
		key = "u",
		description = "set layout: tile.bottom",
		group = "layout",
		on_press = function()
			set_layout_by_name("tilebottom")
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.alt },
		key = "i",
		description = "set layout: tile.top",
		group = "layout",
		on_press = function()
			set_layout_by_name("tiletop")
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.alt },
		key = "d",
		description = "set layout: spiral.dwindle",
		group = "layout",
		on_press = function()
			set_layout_by_name("dwindle")
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.alt },
		key = "m",
		description = "set layout: max",
		group = "layout",
		on_press = function()
			set_layout_by_name("max")
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.alt },
		key = "e",
		description = "set layout: fair",
		group = "layout",
		on_press = function()
			set_layout_by_name("fairv")
		end,
	}),
})

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { mod.super, mod.alt },
		key = "r",
		description = "snap all clients to current layout",
		group = "layout",
		on_press = function()
			local tag = awful.screen.focused().selected_tag
			if not tag then
				return
			end
			for _, c in ipairs(tag:clients()) do
				c.floating = false
				c.maximized = false
				c.fullscreen = false
			end
		end,
	}),
})

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "Left",
		description = "move client to previous tag and follow",
		group = "tag",
		on_press = function()
			if not client.focus then
				return
			end
			local c = client.focus
			local t = c.screen.selected_tag
			if not t then
				return
			end
			local idx = t.index - 1
			local dest = c.screen.tags[idx]
			if dest then
				c:move_to_tag(dest)
				dest:view_only()
			end
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "Right",
		description = "move client to next tag and follow",
		group = "tag",
		on_press = function()
			if not client.focus then
				return
			end

			local c = client.focus
			local t = c.screen.selected_tag

			if not t then
				return
			end

			local idx = t.index + 1
			local dest = c.screen.tags[idx]

			if dest then
				c:move_to_tag(dest)
				dest:view_only()
			end
		end,
	}),
})
