local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local menubar_utils = require("menubar.utils")
local Gio = require("lgi").Gio

local cols = require("config.colors")
local rp = cols.rp

local M = {}

local function rrect(r)
	return function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, r)
	end
end

local function get_all_apps()
	local apps = {}
	local app_infos = Gio.AppInfo.get_all()
	for _, info in ipairs(app_infos) do
		if info:should_show() then
			local name = info:get_display_name() or info:get_name() or ""
			local icon = menubar_utils.lookup_icon(info:get_icon() and info:get_icon():to_string() or "")
			local categories = info:get_categories() or ""
			local exec = info:get_commandline()
			if exec and name ~= "" then
				exec = exec:gsub("%%[fFuUdDnNickvm]", ""):gsub("%s+$", "")
				table.insert(apps, {
					name = name,
					icon = icon,
					exec = exec,
					categories = categories,
					search_name = name:lower(),
				})
			end
		end
	end
	table.sort(apps, function(a, b)
		return a.name:lower() < b.name:lower()
	end)
	return apps
end

local all_apps = nil

local function ensure_apps()
	if not all_apps then
		all_apps = get_all_apps()
	end
	return all_apps
end

local category_map = {
	{ key = "Development", label = " Development", match = "Development" },
	{ key = "Graphics", label = " Graphics", match = "Graphics" },
	{ key = "Internet", label = "󰖟 Internet", match = "Network" },
	{ key = "Multimedia", label = " Multimedia", match = "Audio;Video;Multimedia" },
	{ key = "Office", label = " Office", match = "Office" },
	{ key = "System", label = " System", match = "System" },
	{ key = "Settings", label = " Settings", match = "Settings" },
	{ key = "Utilities", label = " Utilities", match = "Utility" },
	{ key = "Games", label = "󰊗 Games", match = "Game" },
}

local launcher_popup = nil
local submenu_popup = nil
local search_input = ""
local search_grabber = nil

local function close_launcher()
	if launcher_popup then
		launcher_popup.visible = false
	end
	if submenu_popup then
		submenu_popup.visible = false
	end
	if search_grabber then
		awful.keygrabber.stop(search_grabber)
		search_grabber = nil
	end
	search_input = ""
end

local function make_app_row(app, width)
	local icon_w = wibox.widget({
		image = app.icon,
		resize = true,
		forced_width = 20,
		forced_height = 20,
		widget = wibox.widget.imagebox,
	})

	local name_w = wibox.widget({
		markup = gears.string.xml_escape(app.name),
		font = beautiful.font,
		widget = wibox.widget.textbox,
	})

	local row = wibox.widget({
		{
			{
				icon_w,
				name_w,
				spacing = 8,
				layout = wibox.layout.fixed.horizontal,
			},
			left = 10,
			right = 10,
			top = 6,
			bottom = 6,
			widget = wibox.container.margin,
		},
		bg = rp.surface,
		fg = rp.text,
		shape = rrect(4),
		forced_width = width or 280,
		widget = wibox.container.background,
	})

	row:connect_signal("mouse::enter", function()
		row.bg = rp.overlay
	end)
	row:connect_signal("mouse::leave", function()
		row.bg = rp.surface
	end)
	row:buttons(gears.table.join(awful.button({}, 1, function()
		close_launcher()
		awful.spawn(app.exec)
	end)))

	return row
end

local function make_category_row(cat, on_enter)
	local row = wibox.widget({
		{
			{
				markup = cat.label,
				font = beautiful.font,
				widget = wibox.widget.textbox,
			},
			{
				markup = string.format('<span foreground="%s"></span>', rp.subtle),
				font = beautiful.font,
				widget = wibox.widget.textbox,
			},
			nil,
			layout = wibox.layout.align.horizontal,
		},
		left = 10,
		right = 10,
		top = 7,
		bottom = 7,
		widget = wibox.container.margin,
	})

	local bg = wibox.widget({
		row,
		bg = rp.surface,
		fg = rp.text,
		shape = rrect(4),
		forced_width = 220,
		widget = wibox.container.background,
	})

	bg:connect_signal("mouse::enter", function()
		bg.bg = rp.overlay
		on_enter(bg)
	end)
	bg:connect_signal("mouse::leave", function()
		bg.bg = rp.surface
	end)

	return bg
end

local function show_submenu(anchor_widget, apps_list)
	if submenu_popup then
		submenu_popup.visible = false
	end

	local list = wibox.widget({ layout = wibox.layout.fixed.vertical, spacing = 2 })
	local count = 0
	for _, app in ipairs(apps_list) do
		if count < 20 then
			list:add(make_app_row(app, 260))
			count = count + 1
		end
	end

	submenu_popup = awful.popup({
		widget = {
			list,
			margins = 6,
			widget = wibox.container.margin,
		},
		bg = rp.surface,
		border_color = rp.pine,
		border_width = 2,
		shape = rrect(8),
		ontop = true,
		visible = true,
		placement = false,
	})

	local geo = anchor_widget:geometry()
	local parent_geo = launcher_popup and launcher_popup:geometry() or { x = 0, y = 0 }
	submenu_popup.x = parent_geo.x + parent_geo.width + 4
	submenu_popup.y = parent_geo.y + geo.y - 6
end

local function build_search_results(query)
	local apps = ensure_apps()
	local results = {}
	local q = query:lower()
	for _, app in ipairs(apps) do
		if app.search_name:find(q, 1, true) then
			table.insert(results, app)
			if #results >= 12 then
				break
			end
		end
	end
	return results
end

local function categorize_apps()
	local apps = ensure_apps()
	local cats = {}
	for _, cat in ipairs(category_map) do
		cats[cat.key] = {}
	end
	cats["Other"] = {}

	for _, app in ipairs(apps) do
		local placed = false
		for _, cat in ipairs(category_map) do
			for match_part in cat.match:gmatch("[^;]+") do
				if app.categories:find(match_part) then
					table.insert(cats[cat.key], app)
					placed = true
					break
				end
			end
			if placed then
				break
			end
		end
		if not placed then
			table.insert(cats["Other"], app)
		end
	end
	return cats
end

local function build_main_view()
	local cats = categorize_apps()
	local list = wibox.widget({ layout = wibox.layout.fixed.vertical, spacing = 2 })

	for _, cat in ipairs(category_map) do
		if cats[cat.key] and #cats[cat.key] > 0 then
			local cat_apps = cats[cat.key]
			list:add(make_category_row(cat, function(anchor)
				show_submenu(anchor, cat_apps)
			end))
		end
	end

	if cats["Other"] and #cats["Other"] > 0 then
		list:add(make_category_row({ label = " Other", key = "Other" }, function(anchor)
			show_submenu(anchor, cats["Other"])
		end))
	end

	return list
end

local function build_search_view(query)
	local results = build_search_results(query)
	local list = wibox.widget({ layout = wibox.layout.fixed.vertical, spacing = 2 })

	if #results == 0 then
		list:add(wibox.widget({
			{
				markup = string.format('<span foreground="%s">No results</span>', rp.subtle),
				font = beautiful.font,
				widget = wibox.widget.textbox,
			},
			left = 10,
			top = 6,
			bottom = 6,
			widget = wibox.container.margin,
		}))
	else
		for _, app in ipairs(results) do
			list:add(make_app_row(app, 208))
		end
	end

	return list
end

local function update_launcher_content()
	if not launcher_popup then
		return
	end

	local search_display = wibox.widget({
		{
			{
				markup = string.format(
					'<span foreground="%s"> </span> %s<span foreground="%s">|</span>',
					rp.pine,
					gears.string.xml_escape(search_input),
					rp.iris
				),
				font = beautiful.font,
				widget = wibox.widget.textbox,
			},
			left = 10,
			right = 10,
			top = 8,
			bottom = 8,
			widget = wibox.container.margin,
		},
		bg = rp.overlay,
		shape = rrect(6),
		forced_width = 208,
		widget = wibox.container.background,
	})

	local content
	if search_input == "" then
		if submenu_popup then
			submenu_popup.visible = false
		end
		content = build_main_view()
	else
		if submenu_popup then
			submenu_popup.visible = false
		end
		content = build_search_view(search_input)
	end

	launcher_popup:setup({
		{
			search_display,
			content,
			spacing = 6,
			layout = wibox.layout.fixed.vertical,
		},
		margins = 8,
		widget = wibox.container.margin,
	})
end

function M.toggle()
	if launcher_popup and launcher_popup.visible then
		close_launcher()
		return
	end

	search_input = ""

	if not launcher_popup then
		launcher_popup = awful.popup({
			widget = wibox.widget({}),
			bg = rp.surface,
			border_color = rp.pine,
			border_width = 2,
			shape = rrect(10),
			ontop = true,
			visible = false,
			placement = false,
		})
	end

	update_launcher_content()

	local s = awful.screen.focused()
	local wa = s.workarea
	launcher_popup.x = wa.x + 6
	launcher_popup.y = wa.y + 6
	launcher_popup.visible = true

	search_grabber = awful.keygrabber.run(function(_, key, event)
		if event ~= "press" then
			return
		end

		if key == "Escape" then
			close_launcher()
		elseif key == "BackSpace" then
			search_input = search_input:sub(1, -2)
			update_launcher_content()
		elseif key == "Return" then
			if search_input ~= "" then
				local results = build_search_results(search_input)
				if #results > 0 then
					close_launcher()
					awful.spawn(results[1].exec)
				end
			end
		elseif #key == 1 then
			search_input = search_input .. key
			update_launcher_content()
		end
	end)
end

return M
