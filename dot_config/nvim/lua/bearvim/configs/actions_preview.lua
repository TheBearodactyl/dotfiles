local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		backend = "telescope",
	},

	setup = function(opts)
		require("actions-preview").setup(opts)

		keys.register({
			{
				"<leader>cL",
				require("actions-preview").code_actions,
				desc = "Preview code actions",
			},
		})
	end,

	keys = {},
})
