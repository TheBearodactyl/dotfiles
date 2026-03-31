local config = require("bearvim.core.config")

return config.create({
	options = {},
	setup = function(opts)
		require("smear_cursor").setup(opts)
	end,
})
