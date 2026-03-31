local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local beautiful = require("beautiful")
local gears = require("gears")
local apps = require("config.apps")
local cols = require("config.colors")

local rp = cols.rp
local corner_r = cols.border_radius

local M = {}

local function rrect(r)
	return function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, r)
	end
end

local function hpad(w, l, r)
	return wibox.widget({
		w,
		left = l or 6,
		right = r or 6,
		widget = wibox.container.margin,
	})
end

local function make_popup(anchor_widget, content_widget)
	local p = awful.popup({
		widget = {
			content_widget,
			margins = 10,
			widget = wibox.container.margin,
		},
		bg = rp.surface,
		border_color = rp.pine,
		border_width = beautiful.notification_border_width or 2,
		shape = rrect(corner_r),
		ontop = true,
		visible = false,
		hide_on_right_click = true,
		placement = false,
	})

	local hover_anchor = false
	local hover_popup = false
	local close_timer = gears.timer({
		timeout = 0.25,
		single_shot = true,
		callback = function()
			if not hover_anchor and not hover_popup then
				p.visible = false
			end
		end,
	})

	anchor_widget:connect_signal("mouse::enter", function()
		hover_anchor = true
	end)
	anchor_widget:connect_signal("mouse::leave", function()
		hover_anchor = false
		close_timer:again()
	end)
	p:connect_signal("mouse::enter", function()
		hover_popup = true
	end)
	p:connect_signal("mouse::leave", function()
		hover_popup = false
		close_timer:again()
	end)

	local function toggle()
		if p.visible then
			p.visible = false
			return
		end
		p:move_next_to(anchor_widget, "bottom", 4)
		p.visible = true
	end

	return p, toggle
end

local function make_slider_row(icon, min, max, initial)
	local label = wibox.widget({
		font = beautiful.font,
		markup = string.format('<span foreground="%s">%s</span> <b>%d%%</b>', rp.subtle, icon, initial),
		widget = wibox.widget.textbox,
	})

	local slider = wibox.widget({
		bar_shape = rrect(2),
		bar_height = 4,
		bar_color = rp.overlay,
		bar_active_color = rp.pine,
		handle_color = rp.iris,
		handle_shape = gears.shape.circle,
		handle_width = 14,
		handle_border_color = rp.highlight_high,
		handle_border_width = 1,
		minimum = min or 0,
		maximum = max or 100,
		value = initial or 50,
		forced_height = 22,
		widget = wibox.widget.slider,
	})

	local row = wibox.widget({
		{
			label,
			forced_width = 80,
			widget = wibox.container.constraint,
		},
		{
			slider,
			top = 4,
			bottom = 4,
			widget = wibox.container.margin,
		},
		spacing = 8,
		forced_width = 260,
		layout = wibox.layout.fixed.horizontal,
	})

	return row, slider, label
end

do
	local bar_label = wibox.widget({
		font = beautiful.font,
		markup = " 50%",
		widget = wibox.widget.textbox,
	})

	local audio_content = wibox.widget({
		spacing = 6,
		layout = wibox.layout.fixed.vertical,
	})

	local _, audio_toggle = make_popup(bar_label, audio_content)

	local function update_bar_label(pct, muted)
		local icon = muted and "" or (pct == 0 and "" or "")
		local markup = string.format('<span foreground="%s">%s</span> <b>%d%%</b>', rp.subtle, icon, pct)
		bar_label:set_markup(markup)
	end

	local function refresh_volume()
		awful.spawn.easy_async(
			[[bash -c "pactl get-sink-volume @DEFAULT_SINK@ && pactl get-sink-mute @DEFAULT_SINK@"]],
			function(out)
				local pct = tonumber(out:match("(%d+)%%") or "50")
				local muted = out:find("Mute: yes") ~= nil
				update_bar_label(pct, muted)
			end
		)
	end

	watch(
		[[bash -c "pactl get-sink-volume @DEFAULT_SINK@ && pactl get-sink-mute @DEFAULT_SINK@"]],
		2,
		function(_, stdout)
			local pct = tonumber(stdout:match("(%d+)%%") or "50")
			local muted = stdout:find("Mute: yes") ~= nil
			update_bar_label(pct, muted)
		end
	)

	local function make_section_header(text)
		return wibox.widget({
			markup = string.format('<span foreground="%s"><b>%s</b></span>', rp.subtle, text),
			font = beautiful.font,
			widget = wibox.widget.textbox,
		})
	end

	local function make_device_row(name, is_default, icon, on_click)
		local display_name = name
		if #display_name > 35 then
			display_name = display_name:sub(1, 32) .. "…"
		end

		local row = wibox.widget({
			{
				{
					markup = string.format(
						'<span foreground="%s">%s</span>  %s',
						is_default and rp.pine or rp.subtle,
						is_default and icon or " ",
						gears.string.xml_escape(display_name)
					),
					font = beautiful.font,
					widget = wibox.widget.textbox,
				},
				left = 8,
				right = 8,
				top = 5,
				bottom = 5,
				widget = wibox.container.margin,
			},
			bg = is_default and rp.overlay or rp.surface,
			shape = rrect(4),
			forced_width = 340,
			widget = wibox.container.background,
		})

		row:connect_signal("mouse::enter", function()
			row.bg = rp.overlay
		end)
		row:connect_signal("mouse::leave", function()
			row.bg = is_default and rp.overlay or rp.surface
		end)
		row:buttons(gears.table.join(awful.button({}, 1, on_click)))

		return row
	end

	local function make_app_volume_row(app_name, sink_input_id, volume, icon)
		local _inhibit_app = false

		local app_slider = wibox.widget({
			bar_shape = rrect(2),
			bar_height = 4,
			bar_color = rp.overlay,
			bar_active_color = rp.pine,
			handle_color = rp.iris,
			handle_shape = gears.shape.circle,
			handle_width = 12,
			handle_border_color = rp.highlight_high,
			handle_border_width = 1,
			minimum = 0,
			maximum = 100,
			value = volume,
			forced_height = 20,
			widget = wibox.widget.slider,
		})

		app_slider:connect_signal("property::value", function(_, v)
			if _inhibit_app then
				return
			end
			awful.spawn(string.format("pactl set-sink-input-volume %s %d%%", sink_input_id, v), false)
		end)

		local display = app_name
		if #display > 18 then
			display = display:sub(1, 15) .. "…"
		end

		local row = wibox.widget({
			{
				{
					markup = string.format(
						'<span foreground="%s">%s</span> %s',
						rp.subtle,
						icon or "♫",
						gears.string.xml_escape(display)
					),
					font = beautiful.font,
					forced_width = 120,
					widget = wibox.widget.textbox,
				},
				{
					app_slider,
					top = 4,
					bottom = 4,
					widget = wibox.container.margin,
				},
				{
					markup = string.format('<span foreground="%s"><b>%d%%</b></span>', rp.subtle, volume),
					font = beautiful.font,
					forced_width = 44,
					halign = "right",
					widget = wibox.widget.textbox,
				},
				spacing = 6,
				forced_width = 340,
				layout = wibox.layout.fixed.horizontal,
			},
			left = 8,
			right = 8,
			top = 2,
			bottom = 2,
			widget = wibox.container.margin,
		})

		return row
	end

	local function refresh_audio_popup()
		audio_content:reset()

		audio_content:add(make_section_header(" Output Devices"))

		awful.spawn.easy_async([[bash -c "pactl list sinks short"]], function(sinks_out)
			awful.spawn.easy_async("pactl get-default-sink", function(default_sink)
				default_sink = default_sink:gsub("%s+$", "")

				for line in sinks_out:gmatch("[^\n]+") do
					local id, name = line:match("^(%d+)%s+(%S+)")
					if id and name then
						local sink_id = id
						local sink_name = name
						awful.spawn.easy_async(
							string.format(
								[[bash -c "pactl list sinks | grep -A 1 'Sink #%s' | grep 'Description:' | sed 's/.*Description: //'"]],
								sink_id
							),
							function(desc)
								desc = desc:gsub("%s+$", "")
								if desc == "" then
									desc = sink_name
								end
								local is_default = sink_name == default_sink
								audio_content:add(make_device_row(desc, is_default, "", function()
									awful.spawn("pactl set-default-sink " .. sink_name, false)
									gears.timer.delayed_call(refresh_audio_popup)
								end))
							end
						)
					end
				end
			end)
		end)

		gears.timer.start_new(0.15, function()
			audio_content:add(make_section_header(" Input Devices"))

			awful.spawn.easy_async([[bash -c "pactl list sources short"]], function(sources_out)
				awful.spawn.easy_async("pactl get-default-source", function(default_source)
					default_source = default_source:gsub("%s+$", "")

					for line in sources_out:gmatch("[^\n]+") do
						local id, name = line:match("^(%d+)%s+(%S+)")
						if id and name and not name:find("%.monitor$") then
							local source_name = name
							local source_id = id
							awful.spawn.easy_async(
								string.format(
									[[bash -c "pactl list sources | grep -A 1 'Source #%s' | grep 'Description:' | sed 's/.*Description: //'"]],
									source_id
								),
								function(desc)
									desc = desc:gsub("%s+$", "")
									if desc == "" then
										desc = source_name
									end
									local is_default = source_name == default_source
									audio_content:add(make_device_row(desc, is_default, "", function()
										awful.spawn("pactl set-default-source " .. source_name, false)
										gears.timer.delayed_call(refresh_audio_popup)
									end))
								end
							)
						end
					end
				end)
			end)
			return false
		end)

		gears.timer.start_new(0.3, function()
			awful.spawn.easy_async([[bash -c "pactl list sink-inputs"]], function(si_out)
				local app_entries = {}
				local current_id, current_name, current_vol

				local function flush_app()
					if current_id and current_name then
						table.insert(app_entries, {
							id = current_id,
							name = current_name,
							vol = current_vol or 50,
						})
					end
				end

				for line in si_out:gmatch("[^\n]+") do
					local id = line:match("^Sink Input #(%d+)")
					if id then
						flush_app()
						current_id = id
						current_name = nil
						current_vol = nil
					end

					local vol = line:match("Volume:.-(%d+)%%")
					if vol then
						current_vol = tonumber(vol)
					end

					local app = line:match('application%.name = "(.-)"')
					if app then
						current_name = app
					end
				end
				flush_app()

				if #app_entries > 0 then
					audio_content:add(make_section_header("♫ Application Volumes"))
					for _, entry in ipairs(app_entries) do
						audio_content:add(make_app_volume_row(entry.name, entry.id, entry.vol, "♫"))
					end
				end
			end)
			return false
		end)

		local _, master_slider, master_label = make_slider_row("", 0, 100, 50)
		local _inhibit_master = false

		awful.spawn.easy_async(
			[[bash -c "pactl get-sink-volume @DEFAULT_SINK@ && pactl get-sink-mute @DEFAULT_SINK@"]],
			function(out)
				local pct = tonumber(out:match("(%d+)%%") or "50")
				local muted = out:find("Mute: yes") ~= nil
				local icon = muted and "" or ""
				master_label:set_markup(
					string.format('<span foreground="%s">%s</span> <b>%d%%</b>', rp.subtle, icon, pct)
				)
				_inhibit_master = true
				master_slider.value = pct
				_inhibit_master = false
			end
		)

		master_slider:connect_signal("property::value", function(_, v)
			if _inhibit_master then
				return
			end
			awful.spawn(string.format("pactl set-sink-volume @DEFAULT_SINK@ %d%%", v), false)
			awful.spawn.easy_async([[bash -c "pactl get-sink-mute @DEFAULT_SINK@"]], function(out)
				local muted = out:find("Mute: yes") ~= nil
				update_bar_label(v, muted)
				local icon = muted and "" or ""
				master_label:set_markup(
					string.format('<span foreground="%s">%s</span> <b>%d%%</b>', rp.subtle, icon, v)
				)
			end)
		end)

		local master_row = wibox.widget({
			{
				master_label,
				forced_width = 80,
				widget = wibox.container.constraint,
			},
			{
				master_slider,
				top = 4,
				bottom = 4,
				widget = wibox.container.margin,
			},
			spacing = 8,
			forced_width = 340,
			layout = wibox.layout.fixed.horizontal,
		})

		audio_content:insert(1, master_row)
	end

	bar_label:buttons(gears.table.join(
		awful.button({}, 1, function()
			refresh_audio_popup()
			audio_toggle()
		end),
		awful.button({}, 2, function()
			awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
			refresh_volume()
		end),
		awful.button({}, 4, function()
			awful.spawn.easy_async("pactl set-sink-volume @DEFAULT_SINK@ +5%", function()
				refresh_volume()
			end)
		end),
		awful.button({}, 5, function()
			awful.spawn.easy_async("pactl set-sink-volume @DEFAULT_SINK@ -5%", function()
				refresh_volume()
			end)
		end)
	))

	M.volume = hpad(bar_label)
end

do
	local bar_label = wibox.widget({
		font = beautiful.font,
		markup = " 80%",
		widget = wibox.widget.textbox,
	})

	local slider_row, bright_slider, bright_label = make_slider_row("", 0, 100, 80)
	local _, toggle_popup = make_popup(bar_label, slider_row)

	local _inhibit = false

	local function update_label(pct)
		local icon = pct < 25 and "" or (pct < 75 and "" or "")
		local markup = string.format('<span foreground="%s">%s</span> <b>%d%%</b>', rp.subtle, icon, pct)
		bar_label:set_markup(markup)
		bright_label:set_markup(markup)
		_inhibit = true
		bright_slider.value = pct
		_inhibit = false
	end

	local function refresh_brightness()
		awful.spawn.easy_async("brightnessctl -m info", function(out)
			local pct = tonumber(out:match(",(%d+)%%") or "80")
			update_label(pct)
		end)
	end

	watch("brightnessctl -m info", 2, function(_, stdout)
		local pct = tonumber(stdout:match(",(%d+)%%") or "80")
		update_label(pct)
	end)

	bright_slider:connect_signal("property::value", function(_, v)
		if _inhibit then
			return
		end
		awful.spawn(string.format("brightnessctl set %d%%", v), false)
		update_label(v)
	end)

	bar_label:buttons(gears.table.join(
		awful.button({}, 1, toggle_popup),
		awful.button({}, 4, function()
			awful.spawn.easy_async("brightnessctl set +5%", function()
				refresh_brightness()
			end)
		end),
		awful.button({}, 5, function()
			awful.spawn.easy_async("brightnessctl set 5%-", function()
				refresh_brightness()
			end)
		end)
	))

	M.brightness = hpad(bar_label)
end

do
	local network_list = wibox.widget({
		spacing = 2,
		layout = wibox.layout.fixed.vertical,
	})

	local bar_label = wibox.widget({
		font = beautiful.font,
		markup = " …",
		widget = wibox.widget.textbox,
	})

	local wifi_popup, wifi_toggle = make_popup(bar_label, network_list)

	local pw_popup = nil
	local pw_grabber = nil
	local pw_input = ""

	local function close_pw_popup()
		if pw_popup then
			pw_popup.visible = false
		end
		if pw_grabber then
			awful.keygrabber.stop(pw_grabber)
			pw_grabber = nil
		end
		pw_input = ""
	end

	local function show_password_popup(ssid)
		close_pw_popup()
		pw_input = ""

		local status_label = wibox.widget({
			markup = "",
			font = beautiful.font,
			widget = wibox.widget.textbox,
		})

		local pw_display = wibox.widget({
			markup = string.format('<span foreground="%s">|</span>', rp.iris),
			font = beautiful.font,
			widget = wibox.widget.textbox,
		})

		local function update_pw_display()
			local masked = string.rep("●", #pw_input)
			pw_display:set_markup(string.format('%s<span foreground="%s">|</span>', masked, rp.iris))
		end

		local connect_btn = wibox.widget({
			{
				{
					markup = string.format('<span foreground="%s">Connect</span>', rp.base),
					font = beautiful.font,
					halign = "center",
					widget = wibox.widget.textbox,
				},
				left = 16,
				right = 16,
				top = 6,
				bottom = 6,
				widget = wibox.container.margin,
			},
			bg = rp.pine,
			shape = rrect(6),
			widget = wibox.container.background,
		})

		local cancel_btn = wibox.widget({
			{
				{
					markup = "Cancel",
					font = beautiful.font,
					halign = "center",
					widget = wibox.widget.textbox,
				},
				left = 16,
				right = 16,
				top = 6,
				bottom = 6,
				widget = wibox.container.margin,
			},
			bg = rp.overlay,
			shape = rrect(6),
			widget = wibox.container.background,
		})

		local function do_connect()
			status_label:set_markup(string.format('<span foreground="%s">Connecting…</span>', rp.gold))
			local cmd = string.format(
				"nmcli device wifi connect %s password %s",
				gears.string.shell_escape(ssid),
				gears.string.shell_escape(pw_input)
			)
			awful.spawn.easy_async(cmd, function(_, _, _, exit_code)
				if exit_code == 0 then
					close_pw_popup()
				else
					status_label:set_markup(string.format('<span foreground="%s">Connection failed</span>', rp.love))
				end
			end)
		end

		connect_btn:connect_signal("mouse::enter", function()
			connect_btn.bg = rp.foam
		end)
		connect_btn:connect_signal("mouse::leave", function()
			connect_btn.bg = rp.pine
		end)
		connect_btn:buttons(gears.table.join(awful.button({}, 1, do_connect)))

		cancel_btn:connect_signal("mouse::enter", function()
			cancel_btn.bg = rp.highlight_med
		end)
		cancel_btn:connect_signal("mouse::leave", function()
			cancel_btn.bg = rp.overlay
		end)
		cancel_btn:buttons(gears.table.join(awful.button({}, 1, close_pw_popup)))

		local content = wibox.widget({
			{
				markup = string.format(
					'<span foreground="%s"> </span> Connect to <b>%s</b>',
					rp.pine,
					gears.string.xml_escape(ssid)
				),
				font = beautiful.font,
				widget = wibox.widget.textbox,
			},
			{
				markup = string.format('<span foreground="%s">Password:</span>', rp.subtle),
				font = beautiful.font,
				widget = wibox.widget.textbox,
			},
			{
				{
					pw_display,
					left = 10,
					right = 10,
					top = 8,
					bottom = 8,
					widget = wibox.container.margin,
				},
				bg = rp.overlay,
				shape = rrect(6),
				forced_width = 280,
				widget = wibox.container.background,
			},
			status_label,
			{
				cancel_btn,
				connect_btn,
				spacing = 8,
				layout = wibox.layout.flex.horizontal,
			},
			spacing = 8,
			forced_width = 300,
			layout = wibox.layout.fixed.vertical,
		})

		pw_popup = awful.popup({
			widget = {
				content,
				margins = 14,
				widget = wibox.container.margin,
			},
			bg = rp.surface,
			border_color = rp.pine,
			border_width = 2,
			shape = rrect(corner_r),
			ontop = true,
			visible = true,
			placement = awful.placement.centered,
		})

		pw_grabber = awful.keygrabber.run(function(_, key, event)
			if event ~= "press" then
				return
			end
			if key == "Escape" then
				close_pw_popup()
			elseif key == "Return" then
				do_connect()
			elseif key == "BackSpace" then
				pw_input = pw_input:sub(1, -2)
				update_pw_display()
			elseif #key == 1 then
				pw_input = pw_input .. key
				update_pw_display()
			end
		end)
	end

	local function make_row(markup_str, on_click)
		local tb = wibox.widget({
			font = beautiful.font,
			markup = markup_str,
			forced_width = 260,
			widget = wibox.widget.textbox,
		})
		local bg = wibox.widget({
			tb,
			bg = rp.surface,
			shape = rrect(4),
			widget = wibox.container.background,
		})
		bg:connect_signal("mouse::enter", function()
			bg.bg = rp.overlay
		end)
		bg:connect_signal("mouse::leave", function()
			bg.bg = rp.surface
		end)
		bg:buttons(gears.table.join(awful.button({}, 1, on_click)))
		return wibox.widget({
			bg,
			top = 1,
			bottom = 1,
			left = 2,
			right = 2,
			widget = wibox.container.margin,
		})
	end

	local function refresh_wifi_popup()
		network_list:reset()
		awful.spawn.easy_async("nmcli -t -f active,signal,ssid,security dev wifi list", function(stdout)
			local rows = {}
			for line in stdout:gmatch("[^\n]+") do
				local active, sig, ssid, security = line:match("^(yes):(%d+):(.-):(.*)")
				if not active then
					sig, ssid, security = line:match("^no:(%d+):(.-):(.*)")
				end
				if ssid and ssid ~= "" then
					table.insert(rows, {
						ssid = ssid,
						signal = tonumber(sig) or 0,
						active = active ~= nil,
						secured = security and security ~= "" and security ~= "--",
					})
				end
			end
			table.sort(rows, function(a, b)
				return a.signal > b.signal
			end)
			local seen = {}
			local count = 0
			for _, row in ipairs(rows) do
				if not seen[row.ssid] and count < 8 then
					seen[row.ssid] = true
					count = count + 1
					local icon = row.active and "" or ""
					local lock = row.secured and " " or ""
					local color = row.active and rp.pine or rp.text
					local markup = string.format(
						'<span foreground="%s">%s</span>  %s%s  <span foreground="%s">%d%%</span>',
						color,
						icon,
						gears.string.xml_escape(row.ssid),
						lock,
						rp.subtle,
						row.signal
					)
					local ssid_cap = row.ssid
					local is_secured = row.secured
					network_list:add(make_row(markup, function()
						if not row.active then
							wifi_popup.visible = false
							awful.spawn.easy_async(
								string.format(
									"nmcli -t -f name connection show | grep -Fx %s",
									gears.string.shell_escape(ssid_cap)
								),
								function(out)
									if out and out:match("%S") then
										awful.spawn(
											"nmcli connection up " .. gears.string.shell_escape(ssid_cap),
											false
										)
									elseif is_secured then
										show_password_popup(ssid_cap)
									else
										awful.spawn(
											"nmcli device wifi connect " .. gears.string.shell_escape(ssid_cap),
											false
										)
									end
								end
							)
						else
							wifi_popup.visible = false
						end
					end))
				end
			end
			network_list:add(
				make_row(string.format('<span foreground="%s"> Manage networks…</span>', rp.subtle), function()
					awful.spawn(apps.terminal .. " -e nmtui")
					wifi_popup.visible = false
				end)
			)
		end)
	end

	watch("nmcli -t -f active,ssid dev wifi", 5, function(_, stdout)
		local ssid = stdout:match("yes:(.-)\n")
		if ssid and ssid ~= "" then
			bar_label:set_markup(
				string.format(' <span foreground="%s"></span>  %s', rp.pine, gears.string.xml_escape(ssid))
			)
		else
			bar_label:set_markup(string.format('<span foreground="%s">睊  off</span>', rp.subtle))
		end
	end)

	bar_label:buttons(gears.table.join(awful.button({}, 1, function()
		refresh_wifi_popup()
		wifi_toggle()
	end)))

	M.wifi = hpad(bar_label)
end

do
	local bt_list = wibox.widget({
		spacing = 2,
		layout = wibox.layout.fixed.vertical,
	})

	local bar_label = wibox.widget({
		font = beautiful.font,
		markup = "󰂯  bt",
		widget = wibox.widget.textbox,
	})

	local bt_popup, bt_toggle = make_popup(
		bar_label,
		wibox.widget({
			bt_list,
			forced_width = 260,
			widget = wibox.container.constraint,
		})
	)

	local function make_bt_row(markup_str, on_click)
		local tb = wibox.widget({
			font = beautiful.font,
			markup = markup_str,
			forced_width = 256,
			widget = wibox.widget.textbox,
		})
		local bg = wibox.widget({
			tb,
			bg = rp.surface,
			shape = rrect(4),
			widget = wibox.container.background,
		})
		bg:connect_signal("mouse::enter", function()
			bg.bg = rp.overlay
		end)
		bg:connect_signal("mouse::leave", function()
			bg.bg = rp.surface
		end)
		bg:buttons(gears.table.join(awful.button({}, 1, on_click)))
		return wibox.widget({
			bg,
			top = 1,
			bottom = 1,
			left = 2,
			right = 2,
			widget = wibox.container.margin,
		})
	end

	local function refresh_bt_popup()
		bt_list:reset()
		awful.spawn.easy_async("bluetoothctl show", function(show_out)
			local powered = show_out:find("Powered: yes") ~= nil
			local pwr_icon = powered and "󰂯" or "󰂲"
			local pwr_label = powered and "Bluetooth: on" or "Bluetooth: off"
			local pwr_color = powered and rp.pine or rp.subtle
			bt_list:add(
				make_bt_row(
					string.format('<span foreground="%s">%s</span>  %s', pwr_color, pwr_icon, pwr_label),
					function()
						awful.spawn("bluetoothctl power " .. (powered and "off" or "on"), false)
						bt_popup.visible = false
					end
				)
			)
			if not powered then
				return
			end
			awful.spawn.easy_async("bluetoothctl paired-devices", function(paired_out)
				for mac, name in paired_out:gmatch("Device (%S+) (.-)\n") do
					local mac_cap = mac
					local name_cap = name
					awful.spawn.easy_async("bluetoothctl info " .. mac, function(info_out)
						local connected = info_out:find("Connected: yes") ~= nil
						local icon = connected and "󰂱" or "󰂴"
						local color = connected and rp.pine or rp.text
						local action = connected and "Disconnect" or "Connect"
						bt_list:add(
							make_bt_row(
								string.format(
									'<span foreground="%s">%s</span>  %s  <span foreground="%s">%s</span>',
									color,
									icon,
									gears.string.xml_escape(name_cap),
									rp.subtle,
									action
								),
								function()
									awful.spawn(
										(connected and "bluetoothctl disconnect " or "bluetoothctl connect ") .. mac_cap,
										false
									)
									bt_popup.visible = false
								end
							)
						)
					end)
				end
			end)
		end)
	end

	watch(
		[[bash -c "bluetoothctl show | grep 'Powered' && bluetoothctl info 2>/dev/null | grep 'Name' | head -1"]],
		5,
		function(_, stdout)
			local powered = stdout:find("Powered: yes") ~= nil
			if not powered then
				bar_label:set_markup(string.format('<span foreground="%s">󰂲  off</span>', rp.subtle))
				return
			end
			local name = stdout:match("Name: (.-)%s*\n")
			if name then
				bar_label:set_markup(
					string.format('<span foreground="%s">󰂱</span>  %s', rp.pine, gears.string.xml_escape(name))
				)
			else
				bar_label:set_markup(string.format('<span foreground="%s">󰂯</span>  on', rp.pine))
			end
		end
	)

	bar_label:buttons(gears.table.join(awful.button({}, 1, function()
		refresh_bt_popup()
		bt_toggle()
	end)))

	M.bluetooth = hpad(bar_label)
end

return M
