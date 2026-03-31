local config = require("bearvim.core.config")

return config.create({
	options = {
		cursor_line_only = true,
		default_config = {
			prefix_string = " | ",
		},
	},

	setup = function(opts)
		require("nvim-biscuits").setup(opts)
	end,
})
