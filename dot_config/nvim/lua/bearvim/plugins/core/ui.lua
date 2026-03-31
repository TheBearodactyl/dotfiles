local plugin = require("bearvim.core.plugin")

return {
	plugin.spec({
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		setup = require("bearvim.configs.lualine").setup,
		event = "VimEnter",
	}),

	plugin.spec({
		"folke/which-key.nvim",
		event = "VimEnter",
		setup = require("bearvim.configs.which_key").setup,
		opts = require("bearvim.configs.which_key").options,
	}),

	plugin.spec({
		"catppuccin/nvim",
		name = "catppuccin",
		setup = function()
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	}),

	plugin.spec({
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		setup = require("bearvim.configs.alpha").setup,
	}),

	plugin.spec({
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false,
		build = ":TSUpdate",
		opts = require("bearvim.configs.treesitter").options,
		setup = require("bearvim.configs.treesitter").setup,
	}),
}
