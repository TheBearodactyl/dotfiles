local config = require("bearvim.core.config")
local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})

return config.create({
	options = {},
	setup = function(opts)
		require("go").setup(opts)
	end,

	autocmds = {
		{
			event = "BufWritePre",
			pattern = "*.go",
			group = format_sync_grp,
			callback = function(_)
				require("go.format").goimports()
			end,
		},
	},
})
