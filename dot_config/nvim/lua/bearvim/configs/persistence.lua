local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		dir = vim.fn.stdpath("state") .. "/sessions/",
		options = {
			"buffers",
			"curdir",
			"tabpages",
			"winsize",
			"help",
			"globals",
			"skiprtp",
			"folds",
		},
		pre_save = nil,
		post_save = nil,
		save_empty = false,
	},

	setup = function(opts)
		require("persistence").setup(opts)

		keys.register({
			keys.group("<leader>q", "[Q]uit / Session"),
			{
				"<leader>qs",
				function()
					require("persistence").save()
				end,
				desc = "[Q]uit [S]ave Session",
			},
			{
				"<leader>qr",
				function()
					require("persistence").load()
				end,
				desc = "[Q]uit [R]estore Session",
			},
			{
				"<leader>qR",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "[Q]uit [R]estore Last Session",
			},
			{
				"<leader>qd",
				function()
					require("persistence").stop()
				end,
				desc = "[Q]uit [D]on't Save Current Session",
			},
		})
	end,
})
