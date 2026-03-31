local config = require("bearvim.core.config")

return config.create({
	options = {
		highlight = {
			enable = true,
		},
	},
	setup = function(opts)
		if type(opts.ensure_installed) == "table" then
			vim.list_extend(opts.ensure_installed, { "gleam" })
		end

		require("nvim-treesitter.configs").setup(opts)
	end,
})
