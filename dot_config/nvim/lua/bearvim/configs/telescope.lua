local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		defaults = {
			prompt_prefix = "   ",
			selection_caret = "  ",
			entry_prefix = "  ",
			initial_mode = "insert",
			selection_strategy = "reset",
			sorting_strategy = "ascending",
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "top",
					preview_width = 0.55,
					results_width = 0.8,
				},
				vertical = {
					mirror = false,
				},
				width = 0.87,
				height = 0.80,
				preview_cutoff = 120,
			},
			file_sorter = require("telescope.sorters").get_fuzzy_file,
			file_ignore_patterns = {
				"^.git/",
				"^node_modules/",
				"^target/",
				"^build/",
				"^dist/",
			},
			generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
			path_display = { "truncate" },
			winblend = 0,
			border = {},
			borderchars = {
				"─",
				"│",
				"─",
				"│",
				"╭",
				"╮",
				"╯",
				"╰",
			},
			color_devicons = true,
			set_env = { ["COLORTERM"] = "truecolor" },
			file_previewer = require("telescope.previewers").vim_buffer_cat.new,
			grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
			qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
			buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
			mappings = {
				n = { ["q"] = require("telescope.actions").close },
			},
		},
		pickers = {
			find_files = {
				find_command = {
					"rg",
					"--files",
					"--hidden",
					"--glob",
					"!**/.git/*",
				},
				theme = "dropdown",
				previewer = false,
			},
			live_grep = {
				additional_args = function(opts)
					return { "--hidden" }
				end,
			},
			buffers = {
				theme = "dropdown",
				previewer = false,
				initial_mode = "normal",
				mappings = {
					i = {
						["<C-d>"] = require("telescope.actions").delete_buffer,
					},
					n = {
						["dd"] = require("telescope.actions").delete_buffer,
					},
				},
			},
		},
		extensions = {
			["ui-select"] = {
				require("telescope.themes").get_dropdown({}),
			},
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	},

	setup = function(opts)
		local telescope = require("telescope")
		telescope.setup(opts)

		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")

		keys.register({
			keys.group("<leader>f", "[F]ind"),
			{
				"<leader>ff",
				"<cmd>Telescope find_files<cr>",
				desc = "[F]ind [F]iles",
			},
			{
				"<leader>fg",
				"<cmd>Telescope live_grep<cr>",
				desc = "[F]ind by [G]rep",
			},
			{
				"<leader>fw",
				"<cmd>Telescope grep_string<cr>",
				desc = "[F]ind [W]ord",
			},
			{
				"<leader>fr",
				"<cmd>Telescope oldfiles<cr>",
				desc = "[F]ind [R]ecent Files",
			},
			{
				"<leader>fb",
				"<cmd>Telescope buffers<cr>",
				desc = "[F]ind [B]uffers",
			},
			{
				"<leader>fh",
				"<cmd>Telescope help_tags<cr>",
				desc = "[F]ind [H]elp",
			},
			{
				"<leader>fk",
				"<cmd>Telescope keymaps<cr>",
				desc = "[F]ind [K]eymaps",
			},
			{
				"<leader>fd",
				"<cmd>Telescope diagnostics<cr>",
				desc = "[F]ind [D]iagnostics",
			},
			{
				"<leader>fs",
				"<cmd>Telescope builtin<cr>",
				desc = "[F]ind [S]elect Telescope",
			},
			{
				"<leader>fc",
				"<cmd>Telescope commands<cr>",
				desc = "[F]ind [C]ommands",
			},
			{
				"<leader>fC",
				"<cmd>Telescope command_history<cr>",
				desc = "[F]ind [C]ommand History",
			},
			{
				"<leader>fm",
				"<cmd>Telescope marks<cr>",
				desc = "[F]ind [M]arks",
			},
			{
				"<leader>fj",
				"<cmd>Telescope jumplist<cr>",
				desc = "[F]ind [J]umplist",
			},
			{
				"<leader>fl",
				"<cmd>Telescope loclist<cr>",
				desc = "[F]ind [L]ocation List",
			},
			{
				"<leader>fq",
				"<cmd>Telescope quickfix<cr>",
				desc = "[F]ind [Q]uickfix",
			},
			{
				"<leader>ft",
				"<cmd>Telescope filetypes<cr>",
				desc = "[F]ind File [T]ypes",
			},

			keys.group("<leader>fg", "[F]ind [G]it"),
			{
				"<leader>fgf",
				"<cmd>Telescope git_files<cr>",
				desc = "[F]ind [G]it [F]iles",
			},
			{
				"<leader>fgc",
				"<cmd>Telescope git_commits<cr>",
				desc = "[F]ind [G]it [C]ommits",
			},
			{
				"<leader>fgb",
				"<cmd>Telescope git_branches<cr>",
				desc = "[F]ind [G]it [B]ranches",
			},
			{
				"<leader>fgs",
				"<cmd>Telescope git_status<cr>",
				desc = "[F]ind [G]it [S]tatus",
			},
			{
				"<leader>fgh",
				"<cmd>Telescope git_stash<cr>",
				desc = "[F]ind [G]it Stas[h]",
			},
		})
	end,

	commands = {
		ListHighlightGroups = {
			callback = function()
				local groups = vim.fn.getcompletion("", "highlight")
				local buf = vim.api.nvim_create_buf(false, true)

				vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, groups)

				local width = math.floor(vim.o.columns * 0.4)
				local height = math.floor(vim.o.lines * 0.6)
				local row = math.floor((vim.o.lines - height) / 2)
				local col = math.floor((vim.o.columns - width) / 2)

				vim.api.nvim_open_win(buf, true, {
					relative = "editor",
					row = row,
					col = col,
					width = width,
					height = height,
					style = "minimal",
					border = "rounded",
				})
			end,
			opts = { desc = "List all available highlight groups" },
		},
	},
})
