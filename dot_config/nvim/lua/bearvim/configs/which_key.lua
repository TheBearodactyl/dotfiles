local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		preset = "modern",
		delay = 200,
		triggers = {
			{ "<auto>", mode = "nixsotc" },
		},
	},

	setup = function(opts)
		local wk = require("which-key")
		wk.setup(opts)
		wk.add(keys.get_which_key_specs())

		keys.register({
			{ "<C-h>", "<C-w>h", desc = "Move to Left Window" },
			{ "<C-j>", "<C-w>j", desc = "Move to Lower Window" },
			{ "<C-k>", "<C-w>k", desc = "Move to Upper Window" },
			{ "<C-l>", "<C-w>l", desc = "Move to Right Window" },

			{ "<C-Up>", "<cmd>resize +2<cr>", desc = "Increase Window Height" },
			{ "<C-Down>", "<cmd>resize -2<cr>", desc = "Decrease Window Height" },
			{
				"<C-Left>",
				"<cmd>vertical resize -2<cr>",
				desc = "Decrease Window Width",
			},
			{
				"<C-Right>",
				"<cmd>vertical resize +2<cr>",
				desc = "Increase Window Width",
			},

			{ "<A-j>", "<cmd>m .+1<cr>==", desc = "Move Line Down", mode = "n" },
			{ "<A-k>", "<cmd>m .-2<cr>==", desc = "Move Line Up", mode = "n" },
			{
				"<A-j>",
				"<esc><cmd>m .+1<cr>==gi",
				desc = "Move Line Down",
				mode = "i",
			},
			{ "<A-k>", "<esc><cmd>m .-2<cr>==gi", desc = "Move Line Up", mode = "i" },
			{ "<A-j>", ":m '>+1<cr>gv=gv", desc = "Move Selection Down", mode = "v" },
			{ "<A-k>", ":m '<-2<cr>gv=gv", desc = "Move Selection Up", mode = "v" },

			{ "<", "<gv", desc = "Indent Left", mode = "v" },
			{ ">", ">gv", desc = "Indent Right", mode = "v" },

			{
				"<C-s>",
				"<cmd>w<cr><esc>",
				desc = "Save File",
				mode = { "i", "x", "n", "s" },
			},

			{ "[d", vim.diagnostic.goto_prev, desc = "Previous Diagnostic" },
			{ "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
		})
	end,
})
