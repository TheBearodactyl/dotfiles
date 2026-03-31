local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	--- @type trouble.Config
	options = {
		presets = { inc_rename = true },
		modes = {
			--- @type trouble.Mode
			--- @diagnostic disable-next-line: missing-fields
			diagnostics = {
				mode = "diagnostics",
				auto_open = true,
				auto_close = true,
				open_no_results = true,
				win = {
					type = "split",
					position = "right",
					size = { width = 0.25 },
				},
				preview = {
					type = "float",
					relative = "editor",
					border = "rounded",
					title = "Preview",
					title_pos = "center",
					position = { 0, 2 },
					size = { width = 0.3, height = 0.3 },
					zindex = 200,
				},
			},

			--- @type trouble.Mode
			--- @diagnostic disable-next-line: missing-fields
			symbols = {
				desc = "document symbols",
				mode = "lsp_document_symbols",
				focus = false,
				auto_close = true,
				auto_open = true,
				win = {
					type = "split",
					position = "bottom",
					size = { height = 0.2 },
				},
				filter = {
					any = {
						ft = { "help", "markdown" },
						kind = {
							"Class",
							"Constructor",
							"Enum",
							"Field",
							"Function",
							"Interface",
							"Method",
							"Module",
							"Namespace",
							"Package",
							"Property",
							"Struct",
							"Trait",
						},
					},
				},
			},

			--- @type trouble.Mode
			--- @diagnostic disable-next-line: missing-fields
			lsp_references = {
				params = {
					include_declaration = true,
				},
				win = {
					type = "split",
					position = "right",
				},
			},

			--- @type trouble.Mode
			--- @diagnostic disable-next-line: missing-fields
			lsp_definitions = {
				win = {
					type = "split",
					position = "right",
				},
			},

			--- @type trouble.Mode
			--- @diagnostic disable-next-line: missing-fields
			lsp_implementations = {
				win = {
					type = "split",
					position = "right",
				},
			},

			--- @type trouble.Mode
			--- @diagnostic disable-next-line: missing-fields
			lsp_type_definitions = {
				win = {
					type = "split",
					position = "right",
				},
			},

			--- @type trouble.Mode
			--- @diagnostic disable-next-line: missing-fields
			telescope = {
				desc = "Telescope results",
				mode = "telescope",
			},

			--- @type trouble.Mode
			--- @diagnostic disable-next-line: missing-fields
			fzf = {
				desc = "FZF-Lua results",
				mode = "fzf",
			},
		},
	},

	setup = function(opts)
		require("trouble").setup(opts)

		local has_telescope, telescope = pcall(require, "telescope")
		if has_telescope then
			local trouble_telescope = require("trouble.sources.telescope")
			telescope.setup({
				defaults = {
					mappings = {
						i = { ["<c-t>"] = trouble_telescope.open },
						n = { ["<c-t>"] = trouble_telescope.open },
					},
				},
			})
		end

		local has_fzf, fzf_config = pcall(require, "fzf-lua.config")
		if has_fzf then
			local fzf_actions = require("trouble.sources.fzf").actions
			fzf_config.defaults.actions.files["ctrl-t"] = fzf_actions.open
		end

		keys.register({
			keys.group("<leader>x", "Trouble"),

			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>xw",
				"<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.WARN<cr>",
				desc = "Warnings (Trouble)",
			},
			{
				"<leader>xe",
				"<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>",
				desc = "Errors (Trouble)",
			},

			{
				"<leader>xs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>xS",
				"<cmd>Trouble symbols toggle focus=false pinned=true<cr>",
				desc = "Symbols Pinned (Trouble)",
			},

			{
				"<leader>xl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xr",
				"<cmd>Trouble lsp_references toggle<cr>",
				desc = "LSP References (Trouble)",
			},
			{
				"<leader>xd",
				"<cmd>Trouble lsp_definitions toggle<cr>",
				desc = "LSP Definitions (Trouble)",
			},
			{
				"<leader>xi",
				"<cmd>Trouble lsp_implementations toggle<cr>",
				desc = "LSP Implementations (Trouble)",
			},
			{
				"<leader>xt",
				"<cmd>Trouble lsp_type_definitions toggle<cr>",
				desc = "LSP Type Definitions (Trouble)",
			},
			{
				"<leader>xI",
				"<cmd>Trouble lsp_incoming_calls toggle<cr>",
				desc = "LSP Incoming Calls (Trouble)",
			},
			{
				"<leader>xO",
				"<cmd>Trouble lsp_outgoing_calls toggle<cr>",
				desc = "LSP Outgoing Calls (Trouble)",
			},

			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},

			{
				"<leader>xT",
				"<cmd>Trouble telescope toggle<cr>",
				desc = "Telescope Results (Trouble)",
			},

			{
				"<leader>xf",
				"<cmd>Trouble fzf toggle<cr>",
				desc = "FZF Results (Trouble)",
			},

			{
				"]x",
				function()
					--- @diagnostic disable-next-line: missing-parameter, missing-fields
					require("trouble").next({ skip_groups = true, jump = true })
				end,
				desc = "Next Trouble Item",
			},
			{
				"[x",
				function()
					--- @diagnostic disable-next-line: missing-parameter, missing-fields
					require("trouble").prev({ skip_groups = true, jump = true })
				end,
				desc = "Previous Trouble Item",
			},
			{
				"]X",
				function()
					--- @diagnostic disable-next-line: missing-parameter, missing-fields
					require("trouble").last({ skip_groups = true, jump = true })
				end,
				desc = "Last Trouble Item",
			},
			{
				"[X",
				function()
					--- @diagnostic disable-next-line: missing-parameter, missing-fields
					require("trouble").first({ skip_groups = true, jump = true })
				end,
				desc = "First Trouble Item",
			},
		})
	end,

	keys = {
		{ "<leader>x", group = "Trouble" },
		{ "<leader>xx", desc = "Diagnostics (Trouble)" },
		{ "<leader>xX", desc = "Buffer Diagnostics (Trouble)" },
		{ "<leader>xw", desc = "Warnings (Trouble)" },
		{ "<leader>xe", desc = "Errors (Trouble)" },
		{ "<leader>xs", desc = "Symbols (Trouble)" },
		{ "<leader>xS", desc = "Symbols Pinned (Trouble)" },
		{ "<leader>xl", desc = "LSP Definitions / references / ... (Trouble)" },
		{ "<leader>xr", desc = "LSP References (Trouble)" },
		{ "<leader>xd", desc = "LSP Definitions (Trouble)" },
		{ "<leader>xi", desc = "LSP Implementations (Trouble)" },
		{ "<leader>xt", desc = "LSP Type Definitions (Trouble)" },
		{ "<leader>xI", desc = "LSP Incoming Calls (Trouble)" },
		{ "<leader>xO", desc = "LSP Outgoing Calls (Trouble)" },
		{ "<leader>xL", desc = "Location List (Trouble)" },
		{ "<leader>xq", desc = "Quickfix List (Trouble)" },
		{ "<leader>xT", desc = "Telescope Results (Trouble)" },
		{ "<leader>xf", desc = "FZF Results (Trouble)" },
		{ "]x", desc = "Next Trouble Item" },
		{ "[x", desc = "Previous Trouble Item" },
		{ "]X", desc = "Last Trouble Item" },
		{ "[X", desc = "First Trouble Item" },
	},
})
