local plugin = require("bearvim.core.plugin")

return {
	plugin.spec({
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		setup = require("bearvim.configs.telescope").setup,
		opts = require("bearvim.configs.telescope").options,
	}),

	plugin.spec({
		"ibhagwan/fzf-lua",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = require("bearvim.configs.fzf").options,
		setup = require("bearvim.configs.fzf").setup,
		keys = require("bearvim.configs.fzf").keys,
	}),
}
