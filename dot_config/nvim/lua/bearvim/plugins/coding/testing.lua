local plugin = require("bearvim.core.plugin")

return {
	plugin.spec({
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			{ "nvim-neotest/neotest-python", optional = true },
			{ "nvim-neotest/neotest-go", optional = true },
			{ "rouge8/neotest-rust", optional = true },
			{ "haydenmeade/neotest-jest", optional = true },
			{ "marilari88/neotest-vitest", optional = true },
		},
		setup = require("bearvim.configs.neotest").setup,
	}),
}
