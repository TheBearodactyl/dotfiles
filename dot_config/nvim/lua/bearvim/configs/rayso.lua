local config = require("bearvim.core.config")

return config.create({
	options = {
		open_cmd = "vivaldi",
	},
	setup = function(opts)
		require("rayso").setup(opts)

		vim.keymap.set("v", "<leader>rs", require("lib.create").create_snippet)
	end,
})
