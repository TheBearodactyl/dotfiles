local plugin = require("bearvim.core.plugin")

return {
	plugin.spec({
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>pm", "<cmd>Mason<cr>", desc = "[P]lugin [M]ason" } },
		build = ":MasonUpdate",
		setup = require("bearvim.configs.mason").setup,
		opts = require("bearvim.configs.mason").options,
	}),

	plugin.spec({
		"williamboman/mason-lspconfig.nvim",
	}),

	plugin.spec({
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		setup = require("bearvim.configs.lspconfig").setup,
		opts = require("bearvim.configs.lspconfig").options,
	}),

	plugin.spec({
		"smjonas/inc-rename.nvim",
		opts = require("bearvim.configs.inc_rename").options,
		keys = require("bearvim.configs.inc_rename").keys,
		setup = require("bearvim.configs.inc_rename").setup,
	}),

	plugin.spec({
		"folke/lazydev.nvim",
		ft = "lua",
		opts = require("bearvim.configs.lazydev").options,
		setup = require("bearvim.configs.lazydev").setup,
	}),

	plugin.spec({
		"b0o/schemastore.nvim",
		event = "VimEnter",
		priority = 1000,
	}),

	plugin.spec({
		"j-hui/fidget.nvim",
		opts = require("bearvim.configs.fidget").options,
	}),

	plugin.spec({
		"Redoxahmii/json-to-types.nvim",
		build = "sh install.sh bun",
		ft = "json",
	}),
}
