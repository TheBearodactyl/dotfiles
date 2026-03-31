local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local M = {}

M.rrect = function(radius)
	return function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, radius)
	end
end

M.rp = {
	base = "#191724",
	surface = "#1f1d2e",
	overlay = "#26233a",
	muted = "#6e6a86",
	subtle = "#908caa",
	text = "#e0def4",
	love = "#eb6f92",
	gold = "#f6c177",
	rose = "#ebbcba",
	pine = "#31748f",
	foam = "#9ccfd8",
	iris = "#c4a7e7",
	highlight_low = "#21202e",
	highlight_med = "#403d52",
	highlight_high = "#524f67",
}

local corner_radius = dpi(10)

M.border_radius = corner_radius
M.font = "0xProto Nerd Font 12"
M.hotkeys_font = "0xProto Nerd Font 12"
M.hotkeys_description_font = "0xProto Nerd Font 11"
M.bg_normal = M.rp.base
M.bg_focus = M.rp.surface
M.bg_urgent = M.rp.love
M.bg_minimize = M.rp.overlay
M.bg_systray = M.rp.surface
M.fg_normal = M.rp.text
M.fg_focus = M.rp.text
M.fg_urgent = M.rp.base
M.fg_minimize = M.rp.muted
M.border_width = dpi(3)
M.border_normal = M.rp.highlight_med
M.border_focus = M.rp.pine
M.border_marked = M.rp.love
M.useless_gap = dpi(8)
M.notification_font = "0xProto Nerd Font 12"
M.notification_bg = M.rp.surface
M.notification_fg = M.rp.text
M.notification_border_width = dpi(2)
M.notification_border_color = M.rp.pine
M.notification_shape = M.rrect(corner_radius)
M.notification_margin = dpi(16)
M.notification_max_width = dpi(480)
M.tooltip_font = "0xProto Nerd Font 11"
M.tooltip_bg = M.rp.overlay
M.tooltip_fg = M.rp.text
M.tooltip_border_width = dpi(1)
M.tooltip_border_color = M.rp.highlight_high
M.tooltip_shape = M.rrect(dpi(6))
M.tooltip_opacity = 0.95
M.taglist_font = "0xProto Nerd Font Bold 11"
M.taglist_bg_focus = M.rp.pine
M.taglist_fg_focus = M.rp.base
M.taglist_bg_urgent = M.rp.love
M.taglist_fg_urgent = M.rp.base
M.taglist_bg_occupied = M.rp.overlay
M.taglist_fg_occupied = M.rp.subtle
M.taglist_bg_empty = M.rp.base
M.taglist_fg_empty = M.rp.highlight_high
M.taglist_bg_volatile = M.rp.gold
M.taglist_fg_volatile = M.rp.base
M.taglist_shape = M.rrect(dpi(4))
M.taglist_shape_focus = M.rrect(dpi(4))
M.tasklist_font = "0xProto Nerd Font 11"
M.tasklist_bg_normal = M.rp.surface
M.tasklist_fg_normal = M.rp.subtle
M.tasklist_bg_focus = M.rp.overlay
M.tasklist_fg_focus = M.rp.text
M.tasklist_bg_urgent = M.rp.love
M.tasklist_fg_urgent = M.rp.base
M.tasklist_bg_minimize = M.rp.highlight_low
M.tasklist_fg_minimize = M.rp.muted
M.tasklist_shape = M.rrect(dpi(4))
M.tasklist_shape_focus = M.rrect(dpi(4))
M.titlebar_bg_normal = M.rp.surface
M.titlebar_fg_normal = M.rp.muted
M.titlebar_bg_focus = M.rp.overlay
M.titlebar_fg_focus = M.rp.text
M.titlebar_font = "0xProto Nerd Font 11"
M.wibar_bg = M.rp.base
M.wibar_fg = M.rp.text
M.wibar_height = dpi(36)
M.wibar_shape = M.rrect(dpi(8))
M.menu_font = "0xProto Nerd Font 12"
M.menu_bg_normal = M.rp.surface
M.menu_bg_focus = M.rp.overlay
M.menu_fg_normal = M.rp.text
M.menu_fg_focus = M.rp.foam
M.menu_border_color = M.rp.highlight_high
M.menu_border_width = dpi(1)
M.menu_height = dpi(26)
M.menu_width = dpi(200)
M.hotkeys_bg = M.rp.surface
M.hotkeys_fg = M.rp.text
M.hotkeys_border_width = dpi(2)
M.hotkeys_border_color = M.rp.pine
M.hotkeys_shape = M.rrect(corner_radius)
M.hotkeys_modifiers_fg = M.rp.iris
M.hotkeys_label_bg = M.rp.overlay
M.hotkeys_label_fg = M.rp.subtle
M.hotkeys_group_margin = dpi(26)
M.prompt_bg = M.rp.overlay
M.prompt_fg = M.rp.text
M.prompt_bg_cursor = M.rp.iris
M.prompt_fg_cursor = M.rp.base
M.prompt_font = "0xProto Nerd Font 12"

return M
