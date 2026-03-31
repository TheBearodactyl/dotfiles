local config = require("bearvim.core.config")

return config.create({
	setup = function(opts)
		require("alpha").setup(require("bearvim.dash").config)
	end,
})
