local config = require("bearvim.core.config")

return config.create({
	options = {},
	setup = function(opts)
		require("nvim-tree").setup(opts)
	end,
})
