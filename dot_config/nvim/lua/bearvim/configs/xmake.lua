local config = require("bearvim.core.config")

return config.create({
	options = {},
	setup = function(opts)
		require("xmake").setup(opts)
	end,
})
