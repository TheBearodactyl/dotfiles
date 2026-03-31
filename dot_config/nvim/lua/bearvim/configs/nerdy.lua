local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		max_recents = 20,
		add_default_keybindings = true,
	},
})
