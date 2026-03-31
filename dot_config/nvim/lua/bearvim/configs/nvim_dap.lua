local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	setup = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			ensure_installed = {
				"codelldb",
			},
			handlers = {},
		})

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
				args = { "--port", "${port}" },
			},
		}

		dap.configurations.rust = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input(
						"Path to executable: ",
						vim.fn.getcwd() .. "/target/debug/",
						"file"
					)
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input(
						"Path to executable: ",
						vim.fn.getcwd() .. "/",
						"file"
					)
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
		}

		dap.configurations.c = dap.configurations.cpp

		vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
		vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#ffa500" })
		vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
		vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })

		vim.fn.sign_define(
			"DapBreakpoint",
			{ text = "●", texthl = "DapBreakpoint" }
		)
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "◐", texthl = "DapBreakpointCondition" }
		)
		vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint" })
		vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped" })

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
			mappings = {
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.25 },
						"breakpoints",
						"stacks",
						"watches",
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						"repl",
						"console",
					},
					size = 0.25,
					position = "bottom",
				},
			},
			controls = {
				enabled = true,
				element = "repl",
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
			floating = {
				max_height = nil,
				max_width = nil,
				border = "single",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
		})

		keys.register({
			keys.group("<leader>d", "[D]ebug"),
			{
				"<leader>db",
				function()
					dap.toggle_breakpoint()
				end,
				desc = "[D]ebug Toggle [B]reakpoint",
			},
			{
				"<leader>dB",
				function()
					dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "[D]ebug [B]reakpoint Condition",
			},
			{
				"<leader>dc",
				function()
					dap.continue()
				end,
				desc = "[D]ebug [C]ontinue",
			},
			{
				"<leader>di",
				function()
					dap.step_into()
				end,
				desc = "[D]ebug Step [I]nto",
			},
			{
				"<leader>do",
				function()
					dap.step_over()
				end,
				desc = "[D]ebug Step [O]ver",
			},
			{
				"<leader>du",
				function()
					dap.step_out()
				end,
				desc = "[D]ebug Step O[u]t",
			},
			{
				"<leader>dr",
				function()
					dap.repl.open()
				end,
				desc = "[D]ebug [R]EPL",
			},
			{
				"<leader>dl",
				function()
					dap.run_last()
				end,
				desc = "[D]ebug Run [L]ast",
			},
			{
				"<leader>dt",
				function()
					dapui.toggle()
				end,
				desc = "[D]ebug [T]oggle UI",
			},
			{
				"<leader>de",
				function()
					dapui.eval()
				end,
				desc = "[D]ebug [E]val Expression",
			},
		})
	end,
})
