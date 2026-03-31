local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		diagnostics = {
			underline = true,
			update_in_insert = false,
			virtual_text = {
				spacing = 4,
				source = "if_many",
				prefix = "●",
			},
			severity_sort = true,
		},
		inlay_hints = { enabled = true },
		codelens = { enabled = true },
		document_highlight = { enabled = true },
		capabilities = {},
		format = {
			formatting_options = nil,
			timeout_ms = nil,
		},
		servers = {
			pyright = {
				settings = {
					python = {
						analysis = { typeCheckingMode = "basic" },
					},
				},
				ft = { ".py", ".rpy" },
			},
			jsonls = {},
			taplo = {
				filetypes = { "toml" },
			},
		},
	},

	autocmds = {
		{
			event = "LspAttach",
			callback = function(event)
				local map = keys.lsp(event)
				local client = vim.lsp.get_client_by_id(event.data.client_id)

				map({
					{
						"gd",
						function()
							require("telescope.builtin").lsp_definitions()
						end,
						desc = "[G]oto [D]efinition",
					},
					{
						"gr",
						function()
							require("telescope.builtin").lsp_references()
						end,
						desc = "[G]oto [R]eferences",
					},
					{
						"gI",
						function()
							require("telescope.builtin").lsp_implementations()
						end,
						desc = "[G]oto [I]mplementation",
					},
					{
						"gD",
						vim.lsp.buf.declaration,
						desc = "[G]oto [D]eclaration",
					},
					{ "K", vim.lsp.buf.hover, desc = "Hover Documentation" },
					{
						"<C-k>",
						vim.lsp.buf.signature_help,
						desc = "Signature Help",
						mode = "i",
					},
				})

				if
					client
					and client.server_capabilities.documentHighlightProvider
				then
					local highlight_augroup = vim.api.nvim_create_augroup(
						"lsp-highlight",
						{ clear = false }
					)
					vim.api.nvim_create_autocmd(
						{ "CursorHold", "CursorHoldI" },
						{
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						}
					)
					vim.api.nvim_create_autocmd(
						{ "CursorMoved", "CursorMovedI" },
						{
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						}
					)
				end

				if
					client
					and client.server_capabilities.inlayHintProvider
					and vim.lsp.inlay_hint
				then
					keys.register({
						{
							"<leader>th",
							function()
								vim.lsp.inlay_hint.enable(
									not vim.lsp.inlay_hint.is_enabled()
								)
							end,
							desc = "[T]oggle Inlay [H]ints",
						},
					})
				end

				if client and client.name == "vtsls" then
					if vim.bo.filetype == "vue" then
						--- @diagnostic disable-next-line: assign-type-mismatch
						client.server_capabilities.semanticTokensProvider =
							false
					else
						if
							client.server_capabilities.semanticTokensProvider
						then
							client.server_capabilities.semanticTokensProvider.full =
								true
						end
					end
				end
			end,
		},
	},

	setup = function(opts)
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = " ",
					[vim.diagnostic.severity.INFO] = " ",
				},
				texthl = {
					[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
					[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
					[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
					[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
				},
				numhl = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.HINT] = "",
					[vim.diagnostic.severity.INFO] = "",
				},
			},
		})

		vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend(
			"force",
			capabilities,
			require("blink.cmp").get_lsp_capabilities()
		)

		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(opts.servers),
			handlers = {
				function(server_name)
					local server = opts.servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend(
						"force",
						{},
						capabilities,
						server.capabilities or {}
					)
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})

		local vue_language_server_path = vim.fn.stdpath("data")
			.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

		local tsserver_filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
		}

		local vue_plugin = {
			name = "@vue/typescript-plugin",
			location = vue_language_server_path,
			languages = { "vue" },
		}

		vim.lsp.config("jsonls", {
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					schemaDownload = { enable = true },
					validate = { enable = true },
				},
			},
		})

		vim.lsp.config("zls", {
			cmd = {
				"/home/emilia/.local/share/mise/installs/zls/0.15.1/zls",
			},
			settings = {
				zls = {
					zig_exe_path = "/home/emilia/.local/share/mise/installs/zig/0.15.2/bin/zig",
				},
			},
		})

		vim.lsp.config("hls", {
			cmd = {
				"/home/emilia/.local/bin/haskell-language-server-9.14.1",
			},
			settings = {
				hls = {},
			},
		})

		vim.lsp.config("qmlls", {
			cmd = { "/usr/bin/qmlls6" },
			settings = {
				qmlls = {},
			},
		})

		vim.lsp.config("ocamllsp", {
			cmd = { "ocamllsp" },
			filetypes = {
				"ocaml",
				"menhir",
				"ocamlinterface",
				"ocamllex",
				"reason",
				"dune",
			},
			root_markers = {
				"*.opam",
				"esy.json",
				"package.json",
				".git",
				"dune-project",
				"dune-workspace",
			},
		})

		vim.lsp.config("taplo", {
			filetypes = { "toml" },
			root_markers = { "*.toml", ".git" },
		})

		vim.lsp.config("lua_ls", {
			cmd = { "lua-language-server" },
			filetypes = { "lua" },
			root_markers = { ".luarc.json", ".luarc.jsonc" },
			settings = {
				Lua = {
					runtime = {
						version = "Lua 5.3",
					},
					codeLens = {
						enable = true,
					},
					completion = {
						autoRequire = true,
						callSnippet = "Both",
					},
					diagnostics = {
						workspaceEvent = "OnChange",
						globals = { "vim" },
					},
					doc = {
						regengine = "lua",
					},
					signatureHelp = {
						enabled = true,
					},
					hint = {
						enable = true,
						semicolon = "All",
						arrayIndex = "Enable",
						setType = true,
					},
					type = {
						castNumberToInteger = false,
						checkTableShape = true,
						inferParamType = true,
						inferTableSize = 20,
					},
					workspace = {
						checkThirdParty = false,
					},
				},
			},
		})

		vim.lsp.config("vtsls", {
			filetypes = tsserver_filetypes,
			settings = {
				vtsls = {
					tsserver = {
						globalPlugins = {
							vue_plugin,
						},
					},
				},
				typescript = {
					inlayHints = {
						parameterNames = { enabled = "literals" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = true },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
				javascript = {
					inlayHints = {
						parameterNames = { enabled = "literals" },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = true },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
			},
			on_attach = function(client, bufnr)
				vim.schedule(function()
					vim.lsp.enable({ "vue_ls" })
				end)
			end,
		})

		vim.lsp.config("vue_ls", {
			cmd = { "vue-language-server", "--stdio" },
			filetypes = { "vue" },
			root_markers = { "package.json", ".git" },
			settings = {
				vue = {
					inlayHints = {
						destructuredProps = {
							enabled = true,
						},
						inlineHandlerLoading = {
							enabled = true,
						},
						missingProps = {
							enabled = true,
						},
						optionsWrapper = {
							enabled = true,
						},
						vBindShorthand = {
							enabled = true,
						},
					},
				},
			},
		})

		vim.lsp.config("html", {
			cmd = { "vscode-html-language-server", "--stdio" },
			filetypes = { "html" },
			root_markers = { "package.json", ".git" },
		})

		vim.lsp.config("cssls", {
			cmd = { "vscode-css-language-server", "--stdio" },
			filetypes = { "css", "scss", "less" },
			root_markers = { "package.json", ".git" },
			settings = {
				css = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
				scss = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
				less = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
			},
		})

		vim.lsp.config("eslint", {
			cmd = { "vscode-eslint-language-server", "--stdio" },
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"vue",
			},
			root_markers = {
				".eslintrc",
				".eslintrc.js",
				".eslintrc.json",
				"package.json",
				".git",
			},
		})

		vim.lsp.config("clangd", {
			cmd = { "clangd" },
			filetypes = { "c", "cpp", "objc", "objcpp" },
			root_markers = {
				"compile_commands.json",
				"compile_flags.txt",
				".git",
			},
		})

		vim.lsp.config("nu", {
			cmd = { "nu", "--lsp" },
			filetypes = { "nu" },
		})

		vim.lsp.enable({
			"gleam",
			"vtsls",
			"html",
			"cssls",
			"eslint",
			"clangd",
			"nu",
			"lua-language-server",
			"lua_ls",
			"qmlls",
			"ocamllsp",
			"hls",
		})

		keys.register({
			{
				"<leader>D",
				function()
					require("telescope.builtin").lsp_type_definitions()
				end,
				desc = "Type [D]efinition",
			},
			{
				"<leader>ds",
				function()
					require("telescope.builtin").lsp_document_symbols()
				end,
				desc = "[D]ocument [S]ymbols",
			},
			{
				"<leader>ws",
				function()
					require("telescope.builtin").lsp_dynamic_workspace_symbols()
				end,
				desc = "[W]orkspace [S]ymbols",
			},
			{ "<leader>rn", vim.lsp.buf.rename, desc = "[R]e[n]ame" },
			{
				"<leader>ca",
				vim.lsp.buf.code_action,
				desc = "[C]ode [A]ction",
			},
		})
	end,
})
