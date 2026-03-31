local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		show_icons = true,
		leader_key = "'",
		buffer_leader_key = "m",
	},

	setup = function(opts)
		local arrow = require("arrow")
		arrow.setup(opts)

		keys.register({
			keys.group("<leader>A", "[A]rrow"),
			{
				"<leader>Ah",
				require("arrow.persist").previous,
				desc = "[A]rrow previous bookmark",
			},

			{
				"<leader>Al",
				require("arrow.persist").next,
				desc = "[A]rrow next bookmark",
			},

			{
				"<leader>At",
				require("arrow.persist").toggle,
				desc = "[A]rrow toggle bookmark",
			},
		})
	end,

	keys = {
		{
			"<leader>A",
			group = "[A]rrow",
		},
	},
})
