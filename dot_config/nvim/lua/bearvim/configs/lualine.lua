local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		options = {
			icons_enabled = vim.g.have_nerd_font,
			theme = "catppuccin-mocha",
			component_separators = "|",
			section_separators = "",
			globalstatus = true,
		},
		sections = {
			lualine_a = {
				{ "mode", right_padding = 2 },
			},
			lualine_b = { "filename", "branch" },
			lualine_c = {
				"%=",
			},
			lualine_x = { "diagnostics" },
			lualine_y = { "filetype", "progress" },
			lualine_z = {
				{ "location", left_padding = 2 },
			},
		},
		inactive_sections = {
			lualine_a = { "filename" },
			lualine_b = {},
			lualine_c = {},
			lualine_x = {},
			lualine_y = {},
			lualine_z = { "location" },
		},
		tabline = {},
		extensions = {},
	},

	setup = function(opts)
		require("lualine").setup(opts)

		keys.register({
			keys.group("<leader>T", "[T]oggle"),
			{
				"<leader>Ts",
				function()
					if vim.opt.laststatus == 0 then
						vim.opt.laststatus = 3
						vim.notify("Statusline enabled", vim.log.levels.INFO)
					else
						vim.opt.laststatus = 0
						vim.notify("Statusline disabled", vim.log.levels.INFO)
					end
				end,
				desc = "[T]oggle [S]tatusline",
			},
		})
	end,
})
