local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

local function create_fzf_keys()
	local static_keys = {
		{ "<leader>f", group = "[F]zF Lua" },
	}

	local subgroup_keys = keys.subgroups("<leader>f", {
		b = {
			name = "Buffers/Files",
			mappings = {
				{ "b", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
				{ "f", "<cmd>FzfLua files<cr>", desc = "Files" },
				{ "o", "<cmd>FzfLua oldfiles<cr>", desc = "Old Files" },
				{ "q", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
				{ "l", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
				{ "L", "<cmd>FzfLua lines<cr>", desc = "Open Buffers Lines" },
				{ "B", "<cmd>FzfLua blines<cr>", desc = "Current Buffer Lines" },
				{
					"t",
					"<cmd>FzfLua treesitter<cr>",
					desc = "Current Buffer Treesitter Symbols",
				},
				{ "a", "<cmd>FzfLua args<cr>", desc = "Argument List" },
			},
		},
		g = {
			name = "Git",
			mappings = {
				{ "f", "<cmd>FzfLua git_files<cr>", desc = "Git Files" },
				{ "s", "<cmd>FzfLua git_status<cr>", desc = "Git Status" },
				{ "c", "<cmd>FzfLua git_commits<cr>", desc = "Git Commit Log (project)" },
				{ "C", "<cmd>FzfLua git_bcommits<cr>", desc = "Git Commit Log (buffer)" },
				{ "b", "<cmd>FzfLua git_blame<cr>", desc = "Git Blame (buffer)" },
				{ "B", "<cmd>FzfLua git_branches<cr>", desc = "Git Branches" },
				{ "w", "<cmd>FzfLua git_worktrees<cr>", desc = "Git Worktrees" },
				{ "t", "<cmd>FzfLua git_tags<cr>", desc = "Git Tags" },
				{ "S", "<cmd>FzfLua git_stash<cr>", desc = "Git Stash" },
			},
		},
		l = {
			name = "LSP/Diagnostics",
			mappings = {
				{ "r", "<cmd>FzfLua lsp_references<cr>", desc = "References" },
				{ "d", "<cmd>FzfLua lsp_definitions<cr>", desc = "Definitions" },
				{ "D", "<cmd>FzfLua lsp_declarations<cr>", desc = "Declarations" },
				{ "t", "<cmd>FzfLua lsp_typedefs<cr>", desc = "Type Definitions" },
				{ "i", "<cmd>FzfLua lsp_implementations<cr>", desc = "Implementations" },
			},
		},
		m = {
			name = "Misc",
			mappings = {
				{ "h", "<cmd>FzfLua highlights<cr>", desc = "Highlight Groups" },
				{ "m", "<cmd>FzfLua marks<cr>", desc = "Marks" },
				{ "c", "<cmd>FzfLua commands<cr>", desc = "Neovim Commands" },
			},
		},
		c = {
			name = "Completion",
			mappings = {
				{ "p", "<cmd>FzfLua complete_path<cr>", desc = "Complete Path (incl dirs)" },
				{ "f", "<cmd>FzfLua complete_file<cr>", desc = "Complete File (excl dirs)" },
				{ "l", "<cmd>FzfLua complete_path<cr>", desc = "Complete Line (all open buffers)" },
				{ "L", "<cmd>FzfLua complete_bline<cr>", desc = "Complete Line (current buffer only)" },
			},
		},
	})

	return vim.list_extend(static_keys, subgroup_keys)
end

return config.create({
	options = {},
	setup = function(opts)
		require("fzf-lua").setup(opts)

		local fzf_keys = keys.subgroups("<leader>f", {
			b = {
				name = "Buffers/Files",
			},
		})

		keys.register(fzf_keys)
	end,

	keys = create_fzf_keys(),
})
