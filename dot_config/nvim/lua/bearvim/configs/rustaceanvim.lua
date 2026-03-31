local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		tools = {
			hover_actions = {
				auto_focus = false,
				border = "rounded",
				width = 60,
				height = 30,
			},
			code_actions = {
				ui_select_fallback = true,
			},
			float_win_config = {
				border = "rounded",
				auto_focus = false,
			},
			rustc = {
				default_edition = "2024",
			},
			crate_graph = {
				backend = "x11",
				output = nil,
				full = true,
				enabled_graphviz_backends = {
					"bmp",
					"cgimage",
					"canon",
					"dot",
					"gv",
					"xdot",
					"xdot1.2",
					"xdot1.4",
					"eps",
					"exr",
					"fig",
					"gd",
					"gd2",
					"gif",
					"gtk",
					"ico",
					"cmap",
					"ismap",
					"imap",
					"cmapx",
					"imap_np",
					"cmapx_np",
					"jpg",
					"jpeg",
					"jpe",
					"jp2",
					"json",
					"json0",
					"dot_json",
					"xdot_json",
					"pdf",
					"pic",
					"pct",
					"pict",
					"plain",
					"plain-ext",
					"png",
					"pov",
					"ps",
					"ps2",
					"psd",
					"sgi",
					"svg",
					"svgz",
					"tga",
					"tiff",
					"tif",
					"tk",
					"vml",
					"vmlz",
					"wbmp",
					"webp",
					"xlib",
					"x11",
				},
			},
		},
		server = {
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true)
				end
				local map = keys.lsp({ buf = bufnr })

				map({
					{
						"K",
						function()
							vim.cmd.RustLsp({ "hover", "actions" })
						end,
						desc = "Rust Hover Actions",
					},
					{
						"<leader>a",
						function()
							vim.cmd.RustLsp("codeAction")
						end,
						desc = "Rust Code Action",
					},
					{
						"<leader>dr",
						function()
							vim.cmd.RustLsp("debuggables")
						end,
						desc = "[D]ebug [R]ust",
					},
					{
						"<leader>Rr",
						function()
							vim.cmd.RustLsp("runnables")
						end,
						desc = "[R]ust [R]unnables",
					},
					{
						"<leader>Rt",
						function()
							vim.cmd.RustLsp("testables")
						end,
						desc = "[R]ust [T]estables",
					},
					{
						"<leader>Rm",
						function()
							vim.cmd.RustLsp("expandMacro")
						end,
						desc = "[R]ust Expand [M]acro",
					},
					{
						"<leader>Rc",
						function()
							vim.cmd.RustLsp("openCargo")
						end,
						desc = "[R]ust Open [C]argo.toml",
					},
					{
						"<leader>Rp",
						function()
							vim.cmd.RustLsp("parentModule")
						end,
						desc = "[R]ust [P]arent Module",
					},
					{
						"<leader>Rd",
						function()
							vim.cmd.RustLsp("openDocs")
						end,
						desc = "[R]ust Open [D]ocs",
					},
					{
						"<leader>Re",
						function()
							vim.cmd.RustLsp("explainError")
						end,
						desc = "[R]ust [E]xplain Error",
					},
					{
						"<leader>Rg",
						function()
							vim.cmd.RustLsp("crateGraph")
						end,
						desc = "[R]ust Crate [G]raph",
					},
					{
						"<leader>RR",
						function()
							vim.cmd.RustLsp("reload")
						end,
						desc = "[R]ust [R]eload Workspace",
					},
				})
			end,
			default_settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
						loadOutDirsFromCheck = true,
						buildScripts = {
							enable = true,
						},
					},
					checkOnSave = true,
					procMacro = {
						enable = true,
						ignored = {},
					},
					inlayHints = {
						bindingModeHints = {
							enable = true,
						},
						chainingHints = {
							enable = true,
						},
						closingBraceHints = {
							enable = true,
							minLines = 25,
						},
						closureReturnTypeHints = {
							enable = "never",
						},
						lifetimeElisionHints = {
							enable = "never",
							useParameterNames = false,
						},
						maxLength = 25,
						parameterHints = {
							enable = true,
						},
						reborrowHints = {
							enable = "never",
						},
						renderColons = true,
						typeHints = {
							enable = true,
							hideClosureInitialization = false,
							hideNamedConstructor = false,
						},
					},
				},
			},
		},
	},

	keys = {
		{ "<leader>R", group = "[R]ust" },
		{ "<leader>Rr", desc = "[R]ust [R]unnables" },
		{ "<leader>Rt", desc = "[R]ust [T]estables" },
		{ "<leader>Rd", desc = "[R]ust Open [D]ocs" },
		{ "<leader>Rm", desc = "[R]ust Expand [M]acro" },
		{ "<leader>Rc", desc = "[R]ust Open [C]argo.toml" },
		{ "<leader>Rp", desc = "[R]ust [P]arent Module" },
		{ "<leader>Re", desc = "[R]ust [E]xplain Error" },
		{ "<leader>Rg", desc = "[R]ust Crate [G]raph" },
		{ "<leader>RR", desc = "[R]ust [R]eload Workspace" },
		{ "<leader>dr", desc = "[D]ebug [R]ust" },
	},
})
