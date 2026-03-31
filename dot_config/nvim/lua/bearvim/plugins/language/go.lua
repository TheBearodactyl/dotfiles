local plugin = require("bearvim.core.plugin")

return {
	plugin.spec({
		"ray-x/go.nvim",
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		setup = require("bearvim.configs.go").setup,
		opts = require("bearvim.configs.go").options,
		event = { "CmdlineEnter" },
		ft = { "go", "gomod" },
		build = ":lua require('go.install').update_all_sync()",
	}),
}
