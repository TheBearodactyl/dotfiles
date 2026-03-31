local config = require("bearvim.core.config")

return config.create({
	--- @type CordConfig
	options = {
		enabled = true,
		editor = {
			client = "bearnvim",
			tooltip = "The Motherfucking Neovim Config",
		},
		display = {
			theme = "catppuccin",
			flavor = "accent",
		},
	},
	--- @param opts CordConfig
	setup = function(opts)
		--require("cord").setup(opts)

		--vim.cmd("Cord update")
	end,
})
