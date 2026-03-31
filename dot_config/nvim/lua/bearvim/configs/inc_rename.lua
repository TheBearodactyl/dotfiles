local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

local woah = ""

print(woah)

return config.create({
	options = {},

	setup = function(opts)
		require("inc_rename").setup(opts)

		keys.register({
			{
				"<leader>cR",
				function()
					return ":IncRename " .. vim.fn.expand("<cword>")
				end,
				expr = true,
				desc = "Incrementaly Rename Symbol",
			},
		})
	end,

	keys = {
		{ "<leader>cR", desc = "Incrementaly Rename Symbol" },
	},
})
