local config = require("bearvim.core.config")

return config.create({
	options = {
		library = {
			"lazy.nvim",
		},
	},
	setup = function(opts)
		require("lazydev").setup(opts)
	end,
})
