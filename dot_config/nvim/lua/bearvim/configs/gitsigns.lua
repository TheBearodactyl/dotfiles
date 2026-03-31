local config = require("bearvim.core.config")

return config.create({
	options = {
		signs = {
			add = { text = "" },
			change = { text = "󰏫" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "" },
			untracked = { text = "󰇝" },
		},
		signs_staged = {
			add = { text = "" },
			change = { text = "󰏫" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "" },
			untracked = { text = "󰇝" },
		},
		signcolumn = true,
		numhl = true,
		linehl = false,
		word_diff = false,
		watch_gitdir = {
			follow_files = true,
		},
		auto_attach = true,
		attach_to_untracked = false,
		current_line_blame = true,
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol",
			delay = 1000,
			ignore_whitespace = false,
			virt_text_priority = 100,
			use_focus = true,
		},
		current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
	},

	--- @param opts Gitsigns.Config
	setup = function(opts)
		require("gitsigns").setup(opts)

		local colors = {
			base = "#191724",
			surface = "#1f1d2e",
			overlay = "#26233a",
			muted = "#6e6a86",
			subtle = "#908caa",
			text = "#e0def4",
			love = "#eb6f92",
			gold = "#f6c177",
			rose = "#ebbcba",
			pine = "#31748f",
			foam = "#9ccfd8",
			iris = "#c4a7e7",
			highlight_low = "#21202e",
			highlight_med = "#403d52",
			highlight_high = "#524f67",
		}

		vim.api.nvim_set_hl(
			0,
			"GitSignsAdd",
			{ fg = colors.foam, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsChange",
			{ fg = colors.gold, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsDelete",
			{ fg = colors.love, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsTopdelete",
			{ fg = colors.love, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsChangedelete",
			{ fg = colors.rose, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsUntracked",
			{ fg = colors.iris, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsAddNr",
			{ fg = colors.foam, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsChangeNr",
			{ fg = colors.gold, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsDeleteNr",
			{ fg = colors.love, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsTopdeleteNr",
			{ fg = colors.love, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsChangedeleteNr",
			{ fg = colors.rose, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsUntrackedNr",
			{ fg = colors.iris, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsAddLn",
			{ fg = colors.text, bg = "#1a2a28" }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsChangeLn",
			{ fg = colors.text, bg = "#2a2318" }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsDeleteLn",
			{ fg = colors.text, bg = "#2a1a20" }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsTopdeleteLn",
			{ fg = colors.text, bg = "#2a1a20" }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsChangedeleteLn",
			{ fg = colors.text, bg = "#2a1f20" }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsUntrackedLn",
			{ fg = colors.text, bg = "#221d2a" }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsStagedAdd",
			{ fg = colors.pine, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsStagedChange",
			{ fg = colors.rose, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsStagedDelete",
			{ fg = colors.love, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsStagedChangedelete",
			{ fg = colors.rose, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsStagedTopdelete",
			{ fg = colors.love, bg = colors.base }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsAddPreview",
			{ fg = colors.foam, bg = colors.overlay }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsDeletePreview",
			{ fg = colors.love, bg = colors.overlay }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsCurrentLineBlame",
			{ fg = colors.subtle, bg = colors.base, italic = true }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsAddInline",
			{ fg = colors.base, bg = colors.foam }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsDeleteInline",
			{ fg = colors.text, bg = colors.love }
		)
		vim.api.nvim_set_hl(
			0,
			"GitSignsChangeInline",
			{ fg = colors.base, bg = colors.gold }
		)
	end,
})
