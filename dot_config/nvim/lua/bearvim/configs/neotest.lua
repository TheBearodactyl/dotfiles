local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	setup = function(opts)
		local adapters = {}

		local python_ok, neotest_python = pcall(require, "neotest-python")
		if python_ok then
			table.insert(
				adapters,
				neotest_python({
					dap = { justMyCode = false },
					args = { "--log-level", "DEBUG" },
					runner = "pytest",
				})
			)
		end

		local go_ok, neotest_go = pcall(require, "neotest-go")
		if go_ok then
			table.insert(
				adapters,
				neotest_go({
					experimental = { test_table = true },
					args = { "-count=1", "-timeout=60s" },
				})
			)
		end

		local rust_ok, _ = pcall(require, "rustaceanvim.neotest")
		if rust_ok then table.insert(adapters, require("rustaceanvim.neotest")) end

		local jest_ok, neotest_jest = pcall(require, "neotest-jest")
		if jest_ok then
			table.insert(
				adapters,
				neotest_jest({
					jestCommand = "npm test --",
					jestConfigFile = "jest.config.js",
					env = { CI = true },
					cwd = function(path)
						return vim.fn.getcwd()
					end,
				})
			)
		end

		local vitest_ok, neotest_vitest = pcall(require, "neotest-vitest")
		if vitest_ok then table.insert(adapters, neotest_vitest()) end

		local neotest_opts = vim.tbl_deep_extend("force", {
			adapters = adapters,
			benchmark = { enabled = true },
			consumers = {},
			default_strategy = "integrated",
			diagnostic = {
				enabled = true,
				severity = 1,
			},
			discovery = {
				concurrent = 0,
				enabled = true,
			},
			floating = {
				border = "rounded",
				max_height = 0.6,
				max_width = 0.6,
				options = {},
			},
			icons = {
				child_indent = "│",
				child_prefix = "├",
				collapsed = "─",
				expanded = "╮",
				failed = "✖",
				final_child_indent = " ",
				final_child_prefix = "╰",
				non_collapsible = "─",
				notify = "?",
				passed = "✓",
				running = "●",
				running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
				skipped = "○",
				unknown = "?",
				watching = "👁",
			},
			jump = { enabled = true },
			log_level = vim.log.levels.WARN,
			output = {
				enabled = true,
				open_on_run = "short",
			},
			output_panel = {
				enabled = true,
				open = "botright split | resize 15",
			},
			quickfix = {
				enabled = true,
				open = false,
			},
			run = { enabled = true },
			running = { concurrent = true },
			state = { enabled = true },
			status = {
				enabled = true,
				signs = true,
				virtual_text = false,
			},
			strategies = {
				integrated = {
					height = 40,
					width = 120,
				},
			},
			summary = {
				animated = true,
				enabled = true,
				expand_errors = true,
				follow = true,
				mappings = {
					attach = "a",
					clear_marked = "M",
					clear_target = "T",
					debug = "d",
					debug_marked = "D",
					expand = { "<CR>", "<2-LeftMouse>" },
					expand_all = "e",
					help = "?",
					jumpto = "i",
					mark = "m",
					next_failed = "J",
					output = "o",
					prev_failed = "K",
					run = "r",
					run_marked = "R",
					short = "O",
					stop = "u",
					target = "t",
					watch = "w",
				},
				open = "botright vsplit | vertical resize 50",
			},
			watch = {
				enabled = true,
				symbol_queries = {
					python = "class",
					go = "func",
					javascript = "function",
					typescript = "function",
				},
			},
		}, opts or {})

		require("neotest").setup(neotest_opts)

		keys.register({
			keys.group("<leader>t", "[T]est"),
			{
				"<leader>tr",
				function()
					require("neotest").run.run()
				end,
				desc = "[T]est [R]un Nearest",
			},
			{
				"<leader>tR",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "[T]est [R]un File",
			},
			{
				"<leader>ta",
				function()
					require("neotest").run.run(vim.fn.getcwd())
				end,
				desc = "[T]est Run [A]ll",
			},
			{
				"<leader>td",
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "[T]est [D]ebug Nearest",
			},
			{
				"<leader>tD",
				function()
					require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
				end,
				desc = "[T]est [D]ebug File",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "[T]est [S]ummary",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true, auto_close = true })
				end,
				desc = "[T]est [O]utput",
			},
			{
				"<leader>tO",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "[T]est [O]utput Panel",
			},
			{
				"<leader>tw",
				function()
					require("neotest").watch.toggle(vim.fn.expand("%"))
				end,
				desc = "[T]est [W]atch",
			},
			{
				"<leader>tx",
				function()
					require("neotest").run.stop()
				end,
				desc = "[T]test Stop",
			},
			{
				"<leader>tl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "[T]est Run [L]ast",
			},
		})
	end,
})
