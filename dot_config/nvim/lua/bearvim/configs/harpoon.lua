local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		settings = {
			save_on_toggle = false,
			sync_on_ui_close = true,
			key = function()
				return vim.loop.cwd()
			end,
		},
	},

	setup = function(opts)
		local harpoon = require("harpoon")
		harpoon:setup(opts)

		keys.register({
			keys.group("<leader>h", "[H]arpoon"),
			{
				"<leader>ha",
				function()
					harpoon:list():add()
				end,
				desc = "[H]arpoon [A]dd File",
			},
			{
				"<leader>hm",
				function()
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "[H]arpoon [M]enu",
			},
			{
				"<leader>h1",
				function()
					harpoon:list():select(1)
				end,
				desc = "[H]arpoon File [1]",
			},
			{
				"<leader>h2",
				function()
					harpoon:list():select(2)
				end,
				desc = "[H]arpoon File [2]",
			},
			{
				"<leader>h3",
				function()
					harpoon:list():select(3)
				end,
				desc = "[H]arpoon File [3]",
			},
			{
				"<leader>h4",
				function()
					harpoon:list():select(4)
				end,
				desc = "[H]arpoon File [4]",
			},
			{
				"<leader>hp",
				function()
					harpoon:list():prev()
				end,
				desc = "[H]arpoon [P]revious",
			},
			{
				"<leader>hn",
				function()
					harpoon:list():next()
				end,
				desc = "[H]arpoon [N]ext",
			},
			{
				"<C-h>",
				function()
					harpoon:list():select(1)
				end,
				desc = "Harpoon File 1",
			},
			{
				"<C-j>",
				function()
					harpoon:list():select(2)
				end,
				desc = "Harpoon File 2",
			},
			{
				"<C-k>",
				function()
					harpoon:list():select(3)
				end,
				desc = "Harpoon File 3",
			},
			{
				"<C-l>",
				function()
					harpoon:list():select(4)
				end,
				desc = "Harpoon File 4",
			},
		})
	end,
})
