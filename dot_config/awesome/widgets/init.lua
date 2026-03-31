local M = {}

local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local apps = require("config.apps")
local mod = require("bindings.mod")
local statusbar = require("widgets.statusbar")
local pinned = require("config.pinned")

M.awesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},

	{ "manual", apps.manual_cmd },
	{ "edit config", apps.editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },

	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

M.mainmenu = awful.menu({
	items = {
		{ "awesome", M.awesomemenu, beautiful.awesome_icon },
		{ "open terminal", apps.terminal },
		{ "open browser", apps.browser },
	},
})

M.launcher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = M.mainmenu,
})

M.keyboardlayout = awful.widget.keyboardlayout()
M.textclock = wibox.widget.textclock()

M.volume = statusbar.volume
M.brightness = statusbar.brightness
M.wifi = statusbar.wifi
M.bluetooth = statusbar.bluetooth
M.pinned_apps = pinned

function M.create_promptbox()
	return awful.widget.prompt()
end

function M.create_layoutbox(s)
	return awful.widget.layoutbox({
		screen = s,
		buttons = {
			awful.button({
				modifiers = {},
				button = 1,
				on_press = function()
					awful.layout.inc(1)
				end,
			}),
			awful.button({
				modifiers = {},
				button = 3,
				on_press = function()
					awful.layout.inc(-1)
				end,
			}),
			awful.button({
				modifiers = {},
				button = 4,
				on_press = function()
					awful.layout.inc(-1)
				end,
			}),
			awful.button({
				modifiers = {},
				button = 5,
				on_press = function()
					awful.layout.inc(1)
				end,
			}),
		},
	})
end

function M.create_taglist(s)
	return awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = {
			awful.button({
				modifiers = {},
				button = 1,
				on_press = function(t)
					t:view_only()
				end,
			}),
			awful.button({
				modifiers = { mod.super },
				button = 1,
				on_press = function(t)
					if client.focus then
						client.focus:move_to_tag(t)
					end
				end,
			}),
			awful.button({ modifiers = {}, button = 3, on_press = awful.tag.viewtoggle }),
			awful.button({
				modifiers = { mod.super },
				button = 3,
				on_press = function(t)
					if client.focus then
						client.focus:toggle_tag(t)
					end
				end,
			}),
			awful.button({
				modifiers = {},
				button = 4,
				on_press = function(t)
					awful.tag.viewprev(t.screen)
				end,
			}),
			awful.button({
				modifiers = {},
				button = 5,
				on_press = function(t)
					awful.tag.viewnext(t.screen)
				end,
			}),
		},
	})
end

local group_popup = awful.popup({
	widget = wibox.widget({ layout = wibox.layout.fixed.vertical, spacing = 2 }),
	bg = beautiful.bg_focus or "#1f1d2e",
	border_color = beautiful.border_focus or "#31748f",
	border_width = 2,
	shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, 8)
	end,
	ontop = true,
	visible = false,
	placement = false,
})

local group_popup_timer = gears.timer({
	timeout = 0.35,
	single_shot = true,
	callback = function()
		group_popup.visible = false
	end,
})

group_popup:connect_signal("mouse::enter", function()
	group_popup_timer:stop()
end)
group_popup:connect_signal("mouse::leave", function()
	group_popup_timer:again()
end)

local function show_group_popup(icon_widget, clients)
	local list = wibox.widget({ layout = wibox.layout.fixed.vertical, spacing = 2 })

	for _, c in ipairs(clients) do
		local row_bg = wibox.widget({
			{
				{
					awful.widget.clienticon(c),
					forced_width = 20,
					forced_height = 20,
					widget = wibox.container.constraint,
				},
				{
					markup = gears.string.xml_escape(c.name or c.class or "?"),
					font = beautiful.font,
					widget = wibox.widget.textbox,
				},
				spacing = 6,
				layout = wibox.layout.fixed.horizontal,
			},
			left = 8,
			right = 8,
			top = 4,
			bottom = 4,
			widget = wibox.container.margin,
		})

		local bg_wrap = wibox.widget({
			row_bg,
			bg = beautiful.bg_focus,
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, 4)
			end,
			forced_width = 240,
			widget = wibox.container.background,
		})

		bg_wrap:connect_signal("mouse::enter", function()
			bg_wrap.bg = beautiful.bg_minimize or "#26233a"
		end)
		bg_wrap:connect_signal("mouse::leave", function()
			bg_wrap.bg = beautiful.bg_focus
		end)
		bg_wrap:buttons(gears.table.join(awful.button({}, 1, function()
			c:activate({ context = "tasklist", raise = true })
			group_popup.visible = false
		end)))

		list:add(bg_wrap)
	end

	group_popup:setup({
		list,
		margins = 6,
		widget = wibox.container.margin,
	})

	group_popup:move_next_to(icon_widget, "bottom", 4)
	group_popup.visible = true
end

function M.create_tasklist(s)
	local icon_size = 28

	local tasklist_layout = wibox.widget({
		spacing = 4,
		layout = wibox.layout.fixed.horizontal,
	})

	local function update_tasklist()
		tasklist_layout:reset()

		local groups = {}
		local group_order = {}
		local selected = {}
		for _, t in ipairs(s.selected_tags) do
			selected[t] = true
		end

		for _, c in ipairs(s.clients) do
			local dominated2 = false
			for _, ct in ipairs(c:tags()) do
				if selected[ct] then
					dominated2 = true
					break
				end
			end
			if dominated2 then
				local cls = c.class or "unknown"
				if not groups[cls] then
					groups[cls] = {}
					table.insert(group_order, cls)
				end
				table.insert(groups[cls], c)
			end
		end

		local pinned_apps = M.pinned_apps or {}
		local pinned_added = {}

		for _, pin in ipairs(pinned_apps) do
			pinned_added[pin.class] = true
			local clients_for_pin = groups[pin.class]
			local is_running = clients_for_pin and #clients_for_pin > 0

			local icon_img = pin.icon
			if is_running and clients_for_pin[1] then
				icon_img = clients_for_pin[1].icon or pin.icon
			end

			local icon_widget = wibox.widget({
				{
					{
						image = icon_img,
						resize = true,
						forced_width = 20,
						forced_height = 20,
						widget = wibox.widget.imagebox,
					},
					halign = "center",
					valign = "center",
					widget = wibox.container.place,
				},
				forced_width = icon_size,
				forced_height = icon_size,
				shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, 4)
				end,
				bg = is_running and (beautiful.tasklist_bg_focus or "#26233a")
					or (beautiful.tasklist_bg_normal or "#1f1d2e"),
				widget = wibox.container.background,
			})

			local dot_color = is_running and (beautiful.border_focus or "#31748f") or "transparent"
			local multi_dot = is_running and clients_for_pin and #clients_for_pin > 1

			local dot = wibox.widget({
				{
					forced_width = multi_dot and 12 or 6,
					forced_height = 3,
					shape = function(cr, w, h)
						gears.shape.rounded_rect(cr, w, h, 1)
					end,
					bg = dot_color,
					widget = wibox.container.background,
				},
				halign = "center",
				widget = wibox.container.place,
			})

			local full_icon = wibox.widget({
				icon_widget,
				dot,
				spacing = 1,
				layout = wibox.layout.fixed.vertical,
			})

			icon_widget:connect_signal("mouse::enter", function()
				icon_widget.bg = beautiful.tasklist_bg_focus or "#26233a"
				if is_running and #clients_for_pin > 1 then
					group_popup_timer:stop()
					show_group_popup(icon_widget, clients_for_pin)
				end
			end)
			icon_widget:connect_signal("mouse::leave", function()
				icon_widget.bg = is_running and (beautiful.tasklist_bg_focus or "#26233a")
					or (beautiful.tasklist_bg_normal or "#1f1d2e")
				if group_popup.visible then
					group_popup_timer:again()
				end
			end)

			icon_widget:buttons(gears.table.join(
				awful.button({}, 1, function()
					if not is_running then
						awful.spawn(pin.command)
					elseif #clients_for_pin == 1 then
						clients_for_pin[1]:activate({ context = "tasklist", action = "toggle_minimization" })
					end
				end),
				awful.button({}, 3, function()
					if is_running then
						awful.menu.client_list({ theme = { width = 250 } })
					end
				end)
			))

			tasklist_layout:add(full_icon)
		end

		for _, cls in ipairs(group_order) do
			if not pinned_added[cls] then
				local clients_in_group = groups[cls]
				local c = clients_in_group[1]

				local icon_widget = wibox.widget({
					{
						{
							awful.widget.clienticon(c),
							forced_width = 20,
							forced_height = 20,
							widget = wibox.container.constraint,
						},
						halign = "center",
						valign = "center",
						widget = wibox.container.place,
					},
					forced_width = icon_size,
					forced_height = icon_size,
					shape = function(cr, w, h)
						gears.shape.rounded_rect(cr, w, h, 4)
					end,
					bg = (c == client.focus) and (beautiful.tasklist_bg_focus or "#26233a")
						or (beautiful.tasklist_bg_normal or "#1f1d2e"),
					widget = wibox.container.background,
				})

				local multi_dot = #clients_in_group > 1
				local dot = wibox.widget({
					{
						forced_width = multi_dot and 12 or 6,
						forced_height = 3,
						shape = function(cr, w, h)
							gears.shape.rounded_rect(cr, w, h, 1)
						end,
						bg = beautiful.border_focus or "#31748f",
						widget = wibox.container.background,
					},
					halign = "center",
					widget = wibox.container.place,
				})

				local full_icon = wibox.widget({
					icon_widget,
					dot,
					spacing = 1,
					layout = wibox.layout.fixed.vertical,
				})

				icon_widget:connect_signal("mouse::enter", function()
					icon_widget.bg = beautiful.tasklist_bg_focus or "#26233a"
					if #clients_in_group > 1 then
						group_popup_timer:stop()
						show_group_popup(icon_widget, clients_in_group)
					end
				end)
				icon_widget:connect_signal("mouse::leave", function()
					icon_widget.bg = (c == client.focus) and (beautiful.tasklist_bg_focus or "#26233a")
						or (beautiful.tasklist_bg_normal or "#1f1d2e")
					if group_popup.visible then
						group_popup_timer:again()
					end
				end)

				icon_widget:buttons(gears.table.join(
					awful.button({}, 1, function()
						if #clients_in_group == 1 then
							c:activate({ context = "tasklist", action = "toggle_minimization" })
						end
					end),
					awful.button({}, 3, function()
						awful.menu.client_list({ theme = { width = 250 } })
					end)
				))

				tasklist_layout:add(full_icon)
			end
		end
	end

	local function delayed_update()
		gears.timer.delayed_call(update_tasklist)
	end

	tag.connect_signal("property::selected", delayed_update)
	client.connect_signal("list", delayed_update)
	client.connect_signal("focus", delayed_update)
	client.connect_signal("unfocus", delayed_update)
	client.connect_signal("property::minimized", delayed_update)
	client.connect_signal("tagged", delayed_update)
	client.connect_signal("untagged", delayed_update)

	delayed_update()

	return tasklist_layout
end

---@param s any
---@param opts {width?: number, pad_left?: number, pad_right?: number, widget: any, x?: number}
function M.create_pill(s, opts)
	local pill_height = beautiful.wibar_height or 36
	local pill_margin = 6

	local pill = wibox({
		screen = s,
		type = "dock",
		ontop = false,
		visible = true,
		height = pill_height,
		width = opts.width or 200,
		bg = beautiful.wibar_bg,
		shape = beautiful.wibar_shape,
		widget = {
			opts.widget,
			left = opts.pad_left or 8,
			right = opts.pad_right or 8,
			widget = wibox.container.margin,
		},
	})

	pill.x = s.geometry.x + (opts.x or 0)
	pill.y = s.geometry.y + pill_margin

	return pill
end

function M.create_pills(s)
	local gap = 6
	local top_margin = 6
	local pill_height = beautiful.wibar_height or 36
	local screen_w = s.geometry.width

	local taglist_widget = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		M.launcher,
		s.taglist,
		s.promptbox,
	})

	local tag_count = #s.tags
	local tag_width = tag_count * 30 + 36 + 8
	local pill1_width = tag_width

	local pill1 = M.create_pill(s, {
		widget = taglist_widget,
		width = pill1_width,
		x = gap,
		pad_left = 4,
		pad_right = 4,
	})

	local right_widget = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		spacing = 4,
		M.keyboardlayout,
		wibox.widget.systray(),
		M.textclock,
		s.layoutbox,
	})

	local pill4_width = 220
	local pill4_x = screen_w - pill4_width - gap

	local pill4 = M.create_pill(s, {
		widget = right_widget,
		width = pill4_width,
		x = pill4_x,
		pad_left = 8,
		pad_right = 8,
	})

	local status_widget = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		spacing = 2,
		M.wifi,
		M.bluetooth,
		M.brightness,
		M.volume,
	})
	local pill3_width = 400
	local pill3_x = pill4_x - pill3_width - gap

	local pill3 = M.create_pill(s, {
		widget = status_widget,
		width = pill3_width,
		x = pill3_x,
		pad_left = 8,
		pad_right = 8,
	})

	local pill2_x = gap + pill1_width + gap
	local pill2_width = pill3_x - pill2_x - gap

	local pill2 = M.create_pill(s, {
		widget = {
			s.tasklist,
			halign = "center",
			widget = wibox.container.place,
		},
		width = math.max(pill2_width, 200),
		x = pill2_x,
		pad_left = 8,
		pad_right = 8,
	})

	s.padding = {
		top = pill_height + top_margin + gap,
		bottom = s.padding and s.padding.bottom or 0,
		left = s.padding and s.padding.left or 0,
		right = s.padding and s.padding.right or 0,
	}

	return { pill1, pill2, pill3, pill4 }
end

return M
