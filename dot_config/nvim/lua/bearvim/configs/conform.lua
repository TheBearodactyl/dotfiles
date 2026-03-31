local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return {
				timeout_ms = 500,
				lsp_fallback = true,
			}
		end,
		formatters = {
			zls = {
				command = "/home/emilia/.local/share/mise/installs/zls/0.15.1/zls",
			},

			ocamlformat = {
				prepend_args = {
					"--if-then-else",
					"vertical",
					"--break-cases",
					"fit-or-vertical",
					"--type-decl",
					"sparse",
				},
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			rust = { "rustfmt", lsp_format = "fallback" },
			go = { "gofumpt" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			vue = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			less = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			ocaml = { "ocamlformat" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			graphql = { "prettier" },
			handlebars = { "prettier" },
			c = { "clang_format" },
			cpp = { "clang_format" },
		},
	},

	setup = function(opts)
		local conform = require("conform")
		conform.setup(opts)

		keys.register({
			keys.group("<leader>c", "[C]ode"),
			{
				"<leader>cf",
				function()
					conform.format({ async = true, lsp_fallback = true })
				end,
				desc = "[C]ode [F]ormat",
				mode = { "n", "v" },
			},
		})
	end,

	commands = {
		FormatDisable = {
			callback = function(args)
				if args.bang then
					vim.b.disable_autoformat = true
					vim.notify(
						"Disabled autoformat for this buffer",
						vim.log.levels.INFO
					)
				else
					vim.g.disable_autoformat = true
					vim.notify(
						"Disabled autoformat globally",
						vim.log.levels.INFO
					)
				end
			end,
			opts = {
				desc = "Disable autoformat-on-save",
				bang = true,
			},
		},

		FormatEnable = {
			callback = function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
				vim.notify("Re-enabled autoformat", vim.log.levels.INFO)
			end,
			opts = {
				desc = "Re-enable autoformat-on-save",
			},
		},

		FormatToggle = {
			callback = function()
				if vim.g.disable_autoformat or vim.b.disable_autoformat then
					vim.b.disable_autoformat = false
					vim.g.disable_autoformat = false
					vim.notify("Enabled autoformat", vim.log.levels.INFO)
				else
					vim.g.disable_autoformat = true
					vim.notify("Disabled autoformat", vim.log.levels.INFO)
				end
			end,
			opts = {
				desc = "Toggle autoformat-on-save",
			},
		},
	},

	autocmds = {
		{
			event = "BufWritePre",
			pattern = { "*.zig", "*.zon" },
			callback = function()
				vim.lsp.buf.code_action({
					context = { only = { "source.fixAll" } },
					apply = true,
				})
			end,
		},

		{
			event = "BufWritePre",
			pattern = { "*.zig", "*.zon" },
			callback = function()
				vim.lsp.buf.format()
			end,
		},

		{
			event = "BufWritePre",
			pattern = { "*.zig", "*.zon" },
			callback = function()
				vim.lsp.buf.code_action({
					context = { only = { "source.organizeImports" } },
					apply = true,
				})
			end,
		},
	},
})
