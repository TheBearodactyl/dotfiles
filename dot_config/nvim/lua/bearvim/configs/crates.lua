local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		text = {
			loading = "   Loading",
			version = "   %s",
			prerelease = "   %s",
			yanked = "   %s",
			nomatch = "   No match",
			upgrade = "   %s",
			error = "   Error fetching crate",
		},
		highlight = {
			loading = "CratesNvimLoading",
			version = "CratesNvimVersion",
			prerelease = "CratesNvimPreRelease",
			yanked = "CratesNvimYanked",
			nomatch = "CratesNvimNoMatch",
			upgrade = "CratesNvimUpgrade",
			error = "CratesNvimError",
		},
		popup = {
			autofocus = false,
			hide_on_select = false,
			copy_register = "\"",
			style = "minimal",
			border = "none",
			show_version_date = false,
			show_dependency_version = true,
			max_height = 30,
			min_width = 20,
			padding = 1,
		},
		lsp = {
			enabled = true,
			on_attach = function() end,
			actions = true,
			completion = true,
			hover = true,
		},
	},

	setup = function(opts)
		require("crates").setup(opts)

		keys.register({
			keys.group("<leader>C", "[C]rates (Rust)"),
			{
				"<leader>Ct",
				function()
					require("crates").toggle()
				end,
				desc = "[C]rates [T]oggle",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>Cr",
				function()
					require("crates").reload()
				end,
				desc = "[C]rates [R]eload",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>Cv",
				function()
					require("crates").show_versions_popup()
				end,
				desc = "[C]rates [V]ersions",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>Cf",
				function()
					require("crates").show_features_popup()
				end,
				desc = "[C]rates [F]eatures",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>Cd",
				function()
					require("crates").show_dependencies_popup()
				end,
				desc = "[C]rates [D]ependencies",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>Cu",
				function()
					require("crates").update_crate()
				end,
				desc = "[C]rates [U]pdate",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>Ca",
				function()
					require("crates").update_all_crates()
				end,
				desc = "[C]rates Update [A]ll",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>CU",
				function()
					require("crates").upgrade_crate()
				end,
				desc = "[C]rates [U]pgrade",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>CA",
				function()
					require("crates").upgrade_all_crates()
				end,
				desc = "[C]rates Upgrade [A]ll",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>CH",
				function()
					require("crates").open_homepage()
				end,
				desc = "[C]rates [H]omepage",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>CR",
				function()
					require("crates").open_repository()
				end,
				desc = "[C]rates [R]epository",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>CD",
				function()
					require("crates").open_documentation()
				end,
				desc = "[C]rates [D]ocumentation",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
			{
				"<leader>CC",
				function()
					require("crates").open_crates_io()
				end,
				desc = "[C]rates [C]rates.io",
				cond = function()
					return vim.bo.filetype == "toml"
				end,
			},
		})
	end,
})
