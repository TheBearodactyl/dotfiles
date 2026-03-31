local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	--- @type blink.cmp.Config
	options = {
		keymap = {
			preset = "enter",
			["<C-space>"] = {
				"show",
				"show_documentation",
				"hide_documentation",
			},
			["<C-e>"] = { "hide" },
			["<C-y>"] = { "select_and_accept" },

			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },

			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },

			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },

			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-g>"] = {
				function()
					require("blink-cmp").show({ providers = { "ripgrep" } })
				end,
			},
		},

		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},

		sources = {
			default = {
				"lazydev",
				"lsp",
				"path",
				"snippets",
				"buffer",
				"ripgrep",
				"nerdfont",
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				buffer = {
					name = "Buffer",
					module = "blink.cmp.sources.buffer",
					opts = {
						get_bufnrs = function()
							return vim.tbl_filter(function(buf)
								local byte_size = vim.api.nvim_buf_get_offset(
									buf,
									vim.api.nvim_buf_line_count(buf)
								)
								return byte_size < 1024 * 1024
							end, vim.api.nvim_list_bufs())
						end,
					},
				},
				snippets = {
					name = "Snippets",
					module = "blink.cmp.sources.snippets",
					opts = {
						friendly_snippets = true,
						search_paths = {
							vim.fn.stdpath("config") .. "/snippets",
						},
						global_snippets = { "all" },
						extended_filetypes = {},
						ignored_filetypes = {},
					},
				},
				path = {
					name = "Path",
					module = "blink.cmp.sources.path",
					opts = {
						trailing_slash = false,
						label_trailing_slash = true,
						show_hidden_files_by_default = true,
						get_cwd = function(context)
							return vim.fn.expand(
								("#%d:p:h"):format(context.bufnr)
							)
						end,
					},
				},
				ripgrep = {
					name = "rg",
					module = "blink-ripgrep",
					score_offset = -150,
					opts = {},
				},
				nerdfont = {
					module = "blink-nerdfont",
					name = "Nerd Fonts",
					score_offset = -15,
					opts = {
						insert = true,
					},
				},
			},
		},

		completion = {
			accept = {
				auto_brackets = {
					enabled = true,
					default_brackets = {
						"(",
						")",
					},
				},
			},
			menu = {
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "kind_icon", "label", "label_description", gap = 2 },
						{ "kind", gap = 1 },
					},
				},
				border = "rounded",
				scrollbar = true,
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 250,
			},
			ghost_text = {
				enabled = true,
			},
			list = {
				max_items = 100,

				selection = {
					preselect = true,
					auto_insert = false,
				},
			},
		},

		signature = {
			enabled = true,
			trigger = {
				enabled = true,
			},
		},

		fuzzy = {
			implementation = "rust",
		},
	},

	--- @param opts blink.cmp.Config
	setup = function(opts)
		local blink = require("blink.cmp")

		vim.api.nvim_set_hl(
			0,
			"BlinkCmpGhostText",
			{ fg = "#818589", italic = true }
		)

		blink.setup(opts)
		keys.register({
			keys.group("<leader>c", "[C]ode"),
			{ "<C-Space>", desc = "Show Completion", mode = "i" },
			{ "<C-e>", desc = "Hide Completion", mode = "i" },
			{ "<C-y>", desc = "Accept Completion", mode = "i" },
			{ "<C-b>", desc = "Scroll Docs Up", mode = "i" },
			{ "<C-f>", desc = "Scroll Docs Down", mode = "i" },
			{ "<C-g>", desc = "Ripgrep search", mode = "i" },
			{ "<Tab>", desc = "Next Snippet", mode = "i" },
			{ "<S-Tab>", desc = "Previous Snippet", mode = "i" },
		})
	end,
})
