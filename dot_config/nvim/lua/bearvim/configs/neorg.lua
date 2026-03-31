local config = require("bearvim.core.config")

return config.create({
	--- @type neorg.configuration.user
	options = {
		load = {
			["core.defaults"] = {},
		},
	},

	--- @param opts neorg.configuration.user
	setup = function(opts)
		require("neorg").setup(opts)
	end,
})
