local plugin = require("bearvim.core.plugin")

return {
	plugin.spec({
		"folke/trouble.nvim",
		opts = require("bearvim.configs.trouble").options,
		keys = require("bearvim.configs.trouble").keys,
		setup = require("bearvim.configs.trouble").setup,
		cmd = "Trouble",
	}),

	plugin.spec({
		"code-biscuits/nvim-biscuits",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = require("bearvim.configs.biscuits").options,
		setup = require("bearvim.configs.biscuits").setup,
	}),

	plugin.spec({
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	}),

	plugin.spec({
		"aznhe21/actions-preview.nvim",
		opts = require("bearvim.configs.actions_preview").options,
		setup = require("bearvim.configs.actions_preview").setup,
	}),
}
