local config = require("bearvim.core.config")

return config.create({
	options = {
		completions = {
			lsp = { enabled = true },
			blink = { enabled = true },
		},
	},
	setup = function(opts)
		require("render-markdown").setup(opts)
	end,
})
