local plugin = require("bearvim.core.plugin")

return {
	plugin.spec({
		"nvim-tree/nvim-tree.lua",
		opts = require("bearvim.configs.nvim_tree").options,
		setup = require("bearvim.configs.nvim_tree").setup,
	}),

	plugin.spec({
		"lewis6991/gitsigns.nvim",
		setup = require("bearvim.configs.gitsigns").setup,
		opts = require("bearvim.configs.gitsigns").options,
	}),

	plugin.spec({
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		setup = require("bearvim.configs.barbar").setup,
		opts = require("bearvim.configs.barbar").options,
		version = "^1.0.0",
	}),

	plugin.spec({
		"smoka7/hop.nvim",
		tag = "v2.7.2",
		opts = require("bearvim.configs.hop").options,
		setup = require("bearvim.configs.hop").setup,
		keys = require("bearvim.configs.hop").keys,
	}),

	plugin.spec({
		"folke/persistence.nvim",
		event = "BufReadPre",
		setup = require("bearvim.configs.persistence").setup,
		opts = require("bearvim.configs.persistence").options,
	}),

	plugin.spec({
		"otavioschwanck/arrow.nvim",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
		},
		opts = require("bearvim.configs.arrow").options,
		setup = require("bearvim.configs.arrow").setup,
	}),

	plugin.spec({
		"brenton-leighton/multiple-cursors.nvim",
		version = "*",
		enabled = false,
		opts = require("bearvim.configs.multi-cursors").options,
		setup = require("bearvim.configs.multi-cursors").setup,
		keys = require("bearvim.configs.multi-cursors").keys,
	}),
}
