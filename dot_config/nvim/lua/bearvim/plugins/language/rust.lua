local plugin = require("bearvim.core.plugin")

return {
	plugin.spec({
		"saecki/crates.nvim",
		tag = "stable",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = { "toml" },
		setup = require("bearvim.configs.crates").setup,
		opts = require("bearvim.configs.crates").options,
	}),

	plugin.spec({
		"mrcjkb/rustaceanvim",
		version = "8.0.4",
		lazy = false,
		ft = { "rust" },
		opts = require("bearvim.configs.rustaceanvim").options,
		setup = require("bearvim.configs.rustaceanvim").setup,
		keys = require("bearvim.configs.rustaceanvim").keys,
	}),
}
