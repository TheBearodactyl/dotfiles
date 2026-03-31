local config = require("bearvim.core.config")

return config.create({
	options = {},
	setup = function(opts)
		require("refactoring").setup(opts)
	end,
})
