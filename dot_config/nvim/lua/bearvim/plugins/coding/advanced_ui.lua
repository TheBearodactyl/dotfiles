local plugin = require("bearvim.core.plugin")

return {
	plugin.spec({
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = require("bearvim.configs.noice").options,
		setup = require("bearvim.configs.noice").setup,
	}),

	plugin.spec({
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		setup = require("bearvim.configs.snacks").setup,
		opts = require("bearvim.configs.snacks").options,
	}),

	plugin.spec({
		"2kabhishek/nerdy.nvim",
		dependencies = { "folke/snacks.nvim" },
		cmd = "Nerdy",
		opts = require("bearvim.configs.nerdy").options,
	}),

	plugin.spec({
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	}),

	plugin.spec({
		"m4xshen/hardtime.nvim",
		enabled = false,
		lazy = false,
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = require("bearvim.configs.hardtime").options,
		setup = require("bearvim.configs.hardtime").setup,
	}),

	plugin.spec({
		"sphamba/smear-cursor.nvim",
		opts = require("bearvim.configs.smear").options,
		setup = require("bearvim.configs.smear").setup,
	}),

	plugin.spec({
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-mini/mini.nvim",
		},
		opts = require("bearvim.configs.markdown").options,
		setup = require("bearvim.configs.markdown").setup,
	}),

	plugin.spec({
		"vyfor/cord.nvim",
		build = ":Cord update",
		opts = require("bearvim.configs.cord").options,
		setup = require("bearvim.configs.cord").setup,
	}),

	plugin.spec({
		"nvim-neorg/neorg",
		lazy = false,
		version = "*",
		opts = require("bearvim.configs.neorg").options,
		setup = require("bearvim.configs.neorg").setup,
	}),

	plugin.spec({
		"TobinPalmer/rayso.nvim",
		opts = require("bearvim.configs.rayso").options,
		setup = require("bearvim.configs.rayso").setup,
	}),

	plugin.spec({ "rktjmp/lush.nvim" }),
	plugin.spec({ "rktjmp/shipwright.nvim" }),
}
