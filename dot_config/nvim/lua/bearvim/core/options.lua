local M = {}

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local options = {
	mouse = "ia",
	clipboard = "unnamedplus",
	swapfile = true,
	backup = true,
	writebackup = true,
	backupdir = "/home/emilia/.local/share/.nvim-bak",
	undofile = true,
	undolevels = 10000,
	updatetime = 250,
	timeoutlen = 300,

	number = true,
	relativenumber = true,
	cursorline = true,
	signcolumn = "yes",
	wrap = false,
	scrolloff = 8,
	sidescrolloff = 8,
	termguicolors = true,
	showmode = false,
	conceallevel = 2,
	pumheight = 10,

	tabstop = 4,
	shiftwidth = 4,
	expandtab = true,
	autoindent = true,
	smartindent = true,
	breakindent = true,
	linebreak = true,

	ignorecase = true,
	smartcase = true,
	inccommand = "split",

	splitright = true,
	splitbelow = true,

	completeopt = "menu,menuone,noselect",
	selectmode = "mouse,key",
	selection = "inclusive",

	lazyredraw = false,
	synmaxcol = 240,
}

---Apply options
---@param opts? table Optional override options
function M.setup(opts)
	opts = vim.tbl_deep_extend("force", options, opts or {})

	for option, value in pairs(opts) do
		local success, err = pcall(function()
			vim.opt[option] = value
		end)

		if not success then
			vim.notify(
				string.format("Failed to set option '%s': %s", option, err),
				vim.log.levels.WARN
			)
		end
	end

	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.g.have_nerd_font = true

	M.setup_autocmds()
	M.setup_keymaps()
end

---Setup core autocommands
function M.setup_autocmds()
	local augroup = vim.api.nvim_create_augroup("CoreOptions", { clear = true })

	local autocmds = {
		{
			event = "TextYankPost",
			desc = "Highlight when yanking text",
			callback = function()
				pcall(vim.highlight.on_yank, { timeout = 200 })
			end,
		},
		{
			event = "BufReadPost",
			desc = "Restore cursor position",
			callback = function()
				local mark = vim.api.nvim_buf_get_mark(0, "\"")
				local lcount = vim.api.nvim_buf_line_count(0)
				if mark[1] > 0 and mark[1] <= lcount then
					pcall(vim.api.nvim_win_set_cursor, 0, mark)
				end
			end,
		},
		{
			event = "BufWritePre",
			desc = "Auto create directories",
			callback = function(event)
				if event.match:match("^%w%w+://") then return end
				local file = (vim.uv or vim.loop).fs_realpath(event.match)
					or event.match
				local dir = vim.fn.fnamemodify(file, ":p:h")
				if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
			end,
		},
		{
			event = "FileType",
			pattern = {
				"qf",
				"help",
				"man",
				"notify",
				"lspinfo",
				"checkhealth",
				"lazy",
				"mason",
				"null-ls-info",
			},
			callback = function(event)
				vim.bo[event.buf].buflisted = false
				vim.keymap.set("n", "q", "<cmd>close<cr>", {
					buffer = event.buf,
					silent = true,
					desc = "Close window",
				})
			end,
		},
	}

	for _, autocmd in ipairs(autocmds) do
		local success, err = pcall(function()
			vim.api.nvim_create_autocmd(autocmd.event, {
				group = augroup,
				pattern = autocmd.pattern,
				callback = autocmd.callback,
				desc = autocmd.desc,
			})
		end)

		if not success then
			vim.notify(
				string.format(
					"Failed to create autocmd '%s': %s",
					autocmd.desc or "unknown",
					err
				),
				vim.log.levels.WARN
			)
		end
	end
end

---Setup core keymaps
function M.setup_keymaps()
	local keymaps = {
		{ "i", "jk", "<ESC>", "Escape insert mode" },
		{ "i", "kj", "<ESC>", "Escape insert mode" },

		{ "n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlights" },

		{
			{ "n", "x" },
			"j",
			"v:count == 0 ? 'gj' : 'j'",
			"Move down",
			{ expr = true, silent = true },
		},
		{
			{ "n", "x" },
			"k",
			"v:count == 0 ? 'gk' : 'k'",
			"Move up",
			{ expr = true, silent = true },
		},

		{ "v", "<", "<gv", "Indent left" },
		{ "v", ">", ">gv", "Indent right" },
		{ "v", "p", "\"_dP", "Paste without yanking" },

		{ "n", "]q", vim.cmd.cnext, "Next quickfix" },
		{ "n", "[q", vim.cmd.cprev, "Previous quickfix" },
		{ "n", "]l", vim.cmd.lnext, "Next loclist" },
		{ "n", "[l", vim.cmd.lprev, "Previous loclist" },
		{ "n", "]b", vim.cmd.bnext, "Next buffer" },
		{ "n", "[b", vim.cmd.bprev, "Previous buffer" },
		{ "n", "]t", vim.cmd.tabnext, "Next tab" },
		{ "n", "[t", vim.cmd.tabprev, "Previous tab" },

		{ "n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol" },
	}

	for _, keymap in ipairs(keymaps) do
		local success, err = pcall(function()
			local modes, key, cmd, desc, opts =
				keymap[1], keymap[2], keymap[3], keymap[4], keymap[5] or {}
			opts.desc = opts.desc or desc
			vim.keymap.set(modes, key, cmd, opts)
		end)

		if not success then
			vim.notify(
				string.format(
					"Failed to set keymap '%s': %s",
					keymap[2] or "unknown",
					err
				),
				vim.log.levels.WARN
			)
		end
	end
end

--- Utility function for setting highlights
--- @param ns integer Namespace ID (use 0 for global)
--- @param name string Name of the highlight group
--- @param opts table Highlight options
function M.highlight(ns, name, opts)
	if type(ns) ~= "number" then error("Namespace must be a number", 2) end
	if type(name) ~= "string" or name == "" then
		error("Name must be a non-empty string", 2)
	end
	if type(opts) ~= "table" then error("Options must be a table", 2) end

	local success, err = pcall(vim.api.nvim_set_hl, ns, name, opts)
	if not success then
		vim.notify(
			string.format("Failed to set highlight '%s': %s", name, err),
			vim.log.levels.WARN
		)
	end
end

M.setup()

return M
