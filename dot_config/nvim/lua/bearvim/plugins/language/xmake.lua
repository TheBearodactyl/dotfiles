local plugin = require("bearvim.core.plugin")

return plugin.spec({
	"Mythos-404/xmake.nvim",
	version = "^3",
	lazy = true,
	event = "BufReadPost",
	config = require("bearvim.configs.xmake").setup,
})
