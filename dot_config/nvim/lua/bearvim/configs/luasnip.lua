local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		history = true,
		delete_check_events = "TextChanged",
		updateevents = "TextChanged,TextChangedI",
		enable_autosnippets = true,
		ext_opts = {
			[1] = {
				active = {
					virt_text = {
						{ "●", "Comment" },
					},
				},
			},
		},
	},

	setup = function(opts)
		local luasnip = require("luasnip")

		local types = require("luasnip.util.types")
		if types and types.choiceNode then
			opts.ext_opts = opts.ext_opts or {}
			opts.ext_opts[types.choiceNode] = {
				active = {
					virt_text = { { "●", "Comment" } },
				},
			}
		end

		luasnip.setup(opts)

		require("luasnip.loaders.from_vscode").lazy_load()

		local custom_snippets_path = vim.fn.stdpath("config") .. "/snippets"
		if vim.fn.isdirectory(custom_snippets_path) == 1 then
			require("luasnip.loaders.from_vscode").lazy_load({
				paths = { custom_snippets_path },
			})
		end

		keys.register({
			{
				"<Tab>",
				function()
					luasnip.jump(1)
				end,
				desc = "Next Snippet Node",
				mode = "s",
			},
			{
				"<S-Tab>",
				function()
					luasnip.jump(-1)
				end,
				desc = "Previous Snippet Node",
				mode = "s",
			},
			{
				"<S-Tab>",
				function()
					if luasnip.jumpable(-1) then luasnip.jump(-1) end
				end,
				desc = "Previous Snippet Node",
				mode = "i",
			},
			{
				"<C-l>",
				function()
					if luasnip.choice_active() then luasnip.change_choice(1) end
				end,
				desc = "Next Choice",
				mode = "i",
			},
		})

		vim.keymap.set("s", "<BS>", "<C-g>c", { noremap = true, silent = true })
	end,
})
