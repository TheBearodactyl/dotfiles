local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		auto_hide = 1,
		animation = true,
		tabpages = true,
		closable = true,
		clickable = true,

		exclude_ft = { "javascript" },
		exclude_name = { "package.json" },

		icons = {
			buffer_index = false,
			buffer_number = false,
			button = "",
			diagnostics = {
				[vim.diagnostic.severity.ERROR] = { enabled = true, icon = "ﬀ" },
				[vim.diagnostic.severity.WARN] = { enabled = false },
				[vim.diagnostic.severity.INFO] = { enabled = false },
				[vim.diagnostic.severity.HINT] = { enabled = true },
			},
			gitsigns = {
				added = { enabled = true, icon = "+" },
				changed = { enabled = true, icon = "~" },
				deleted = { enabled = true, icon = "-" },
			},
			filetype = {
				custom_colors = false,
				enabled = true,
			},
			separator = { left = "▎", right = "" },
			separator_at_end = true,
			modified = { button = "●" },
			pinned = { button = "", filename = true },
			preset = "default",
			alternate = { filetype = { enabled = false } },
			current = { buffer_number = true },
			inactive = { button = "×" },
			visible = { modified = { buffer_number = false } },
		},

		insert_at_end = false,
		insert_at_start = false,
		maximum_padding = 1,
		minimum_padding = 1,
		maximum_length = 30,
		minimum_length = 0,
		semantic_letters = true,
		sidebar_filetypes = {
			NvimTree = true,
			undotree = { text = "undotree" },
			["neo-tree"] = { event = "BufWipeout" },
		},

		letters = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP",
		no_name_title = nil,
	},

	setup = function(opts)
		local barbar = require("barbar")
		barbar.setup(opts)

		keys.register({
			keys.group("<leader>b", "[B]uffer"),

			{ "<leader>bb", "<cmd>BufferPick<cr>", desc = "[B]uffer Pick" },
			{ "<leader>bc", "<cmd>BufferClose<cr>", desc = "[B]uffer [C]lose" },
			{
				"<leader>bC",
				"<cmd>BufferClose!<cr>",
				desc = "[B]uffer [C]lose (Force)",
			},
			{ "<leader>bd", "<cmd>BufferClose<cr>", desc = "[B]uffer [D]elete" },
			{
				"<leader>bD",
				"<cmd>BufferClose!<cr>",
				desc = "[B]uffer [D]elete (Force)",
			},

			{ "<leader>bn", "<cmd>BufferNext<cr>", desc = "[B]uffer [N]ext" },
			{ "<leader>bp", "<cmd>BufferPrevious<cr>", desc = "[B]uffer [P]revious" },
			{ "<leader>b>", "<cmd>BufferMoveNext<cr>", desc = "[B]uffer Move Next" },
			{
				"<leader>b<",
				"<cmd>BufferMovePrevious<cr>",
				desc = "[B]uffer Move Previous",
			},

			{
				"<leader>bo",
				"<cmd>BufferOrderByBufferNumber<cr>",
				desc = "[B]uffer [O]rder by Number",
			},
			{
				"<leader>bl",
				"<cmd>BufferOrderByLanguage<cr>",
				desc = "[B]uffer Order by [L]anguage",
			},
			{
				"<leader>bw",
				"<cmd>BufferOrderByWindowNumber<cr>",
				desc = "[B]uffer Order by [W]indow",
			},

			{ "<leader>bP", "<cmd>BufferPin<cr>", desc = "[B]uffer [P]in" },
			{
				"<leader>bca",
				"<cmd>BufferCloseAllButCurrent<cr>",
				desc = "[B]uffer [C]lose [A]ll But Current",
			},
			{
				"<leader>bcl",
				"<cmd>BufferCloseBuffersLeft<cr>",
				desc = "[B]uffer [C]lose [L]eft",
			},
			{
				"<leader>bcr",
				"<cmd>BufferCloseBuffersRight<cr>",
				desc = "[B]uffer [C]lose [R]ight",
			},

			{ "<A-1>", "<cmd>BufferGoto 1<cr>", desc = "Go to Buffer 1" },
			{ "<A-2>", "<cmd>BufferGoto 2<cr>", desc = "Go to Buffer 2" },
			{ "<A-3>", "<cmd>BufferGoto 3<cr>", desc = "Go to Buffer 3" },
			{ "<A-4>", "<cmd>BufferGoto 4<cr>", desc = "Go to Buffer 4" },
			{ "<A-5>", "<cmd>BufferGoto 5<cr>", desc = "Go to Buffer 5" },
			{ "<A-6>", "<cmd>BufferGoto 6<cr>", desc = "Go to Buffer 6" },
			{ "<A-7>", "<cmd>BufferGoto 7<cr>", desc = "Go to Buffer 7" },
			{ "<A-8>", "<cmd>BufferGoto 8<cr>", desc = "Go to Buffer 8" },
			{ "<A-9>", "<cmd>BufferGoto 9<cr>", desc = "Go to Buffer 9" },
			{ "<A-0>", "<cmd>BufferLast<cr>", desc = "Go to Last Buffer" },

			{ "<A-,>", "<cmd>BufferPrevious<cr>", desc = "Previous Buffer" },
			{ "<A-.>", "<cmd>BufferNext<cr>", desc = "Next Buffer" },
			{ "<A-<>", "<cmd>BufferMovePrevious<cr>", desc = "Move Buffer Left" },
			{ "<A->>", "<cmd>BufferMoveNext<cr>", desc = "Move Buffer Right" },
			{ "<A-c>", "<cmd>BufferClose<cr>", desc = "Close Buffer" },
			{ "<A-p>", "<cmd>BufferPin<cr>", desc = "Pin/Unpin Buffer" },
			{ "<C-p>", "<cmd>BufferPick<cr>", desc = "Buffer Pick Mode" },
		})
	end,

	autocmds = {
		{
			event = "BufWinEnter",
			callback = function()
				local buffers = vim.tbl_filter(function(buf)
					return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
				end, vim.api.nvim_list_bufs())

				if #buffers <= 1 then
					vim.opt.showtabline = 0
				else
					vim.opt.showtabline = 2
				end
			end,
		},
		{
			event = "BufDelete",
			callback = function()
				vim.schedule(function()
					local buffers = vim.tbl_filter(function(buf)
						return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
					end, vim.api.nvim_list_bufs())

					if #buffers <= 1 then vim.opt.showtabline = 0 end
				end)
			end,
		},
	},

	commands = {
		BarbarToggle = {
			callback = function()
				if vim.opt.showtabline:get() == 0 then
					vim.opt.showtabline = 2
					vim.notify("Barbar enabled", vim.log.levels.INFO)
				else
					vim.opt.showtabline = 0
					vim.notify("Barbar disabled", vim.log.levels.INFO)
				end
			end,
			opts = { desc = "Toggle barbar visibility" },
		},

		BarbarCloseAllButPinned = {
			callback = function()
				vim.cmd("BufferCloseAllButPinned")
				vim.notify("Closed all unpinned buffers", vim.log.levels.INFO)
			end,
			opts = { desc = "Close all unpinned buffers" },
		},

		BarbarRestoreSession = {
			callback = function()
				vim.notify("Buffer session restored", vim.log.levels.INFO)
			end,
			opts = { desc = "Restore buffer session" },
		},
	},
})
