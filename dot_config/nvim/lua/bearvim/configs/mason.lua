local config = require("bearvim.core.config")
local keys = require("bearvim.core.keys")

return config.create({
	options = {
		ensure_installed = {
			"lua-language-server",
			"pyright",
			"typescript-language-server",
			"gopls",
			"clangd",
			"json-lsp",
			"yaml-language-server",
			"html-lsp",
			"css-lsp",
			"tailwindcss-language-server",
			"emmet-ls",
			"stylua",
			"prettier",
			"black",
			"isort",
			"gofumpt",
			"clang-format",
			"shfmt",
			"eslint_d",
			"pylint",
			"shellcheck",
			"markdownlint",
			"codelldb",
		},
		ui = {
			border = "rounded",
			width = 0.8,
			height = 0.8,
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
		install_root_dir = vim.fn.stdpath("data") .. "/mason",
		pip = {
			upgrade_pip = false,
			install_args = {},
		},
		log_level = vim.log.levels.INFO,
		max_concurrent_installers = 4,
		registries = {
			"github:mason-org/mason-registry",
		},
	},

	setup = function(opts)
		local mason = require("mason")
		mason.setup(opts)

		local mr = require("mason-registry")

		mr:on("package:install:success", function(pkg)
			vim.notify(
				string.format("Successfully installed %s", pkg.name),
				vim.log.levels.INFO
			)
			vim.defer_fn(function()
				require("lazy.core.handler.event").trigger({
					event = "FileType",
					buf = vim.api.nvim_get_current_buf(),
				})
			end, 100)
		end)

		mr:on("package:install:failed", function(pkg)
			vim.notify(
				string.format("Failed to install %s", pkg.name),
				vim.log.levels.ERROR
			)
		end)

		local function ensure_installed()
			for _, tool in ipairs(opts.ensure_installed) do
				local package = mr.get_package(tool)
				if package and not package:is_installed() then
					vim.notify(
						string.format("Installing %s...", tool),
						vim.log.levels.INFO
					)
					package:install()
				end
			end
		end

		if mr.refresh then
			mr.refresh(ensure_installed)
		else
			ensure_installed()
		end

		keys.register({
			keys.group("<leader>p", "[P]lugins"),
			{ "<leader>pm", "<cmd>Mason<cr>", desc = "[P]lugin [M]ason" },
			{
				"<leader>pM",
				"<cmd>MasonUpdate<cr>",
				desc = "[P]lugin [M]ason Update",
			},
			{ "<leader>pl", "<cmd>Lazy<cr>", desc = "[P]lugin [L]azy" },
		})
	end,

	autocmds = {
		{
			event = "User",
			pattern = "MasonToolsUpdateCompleted",
			callback = function()
				vim.notify("Mason tools update completed!", vim.log.levels.INFO)
			end,
		},
	},

	commands = {
		MasonInstallAll = {
			callback = function()
				local mr = require("mason-registry")
				local config = require("bearvim.configs.mason")

				for _, tool in ipairs(config.options.ensure_installed) do
					local package = mr.get_package(tool)
					if package and not package:is_installed() then package:install() end
				end
				vim.notify(
					"Installing all configured Mason tools...",
					vim.log.levels.INFO
				)
			end,
			opts = { desc = "Install all configured Mason tools" },
		},

		MasonUpdateAll = {
			callback = function()
				local mr = require("mason-registry")
				local installed_packages = mr.get_installed_packages()

				for _, package in ipairs(installed_packages) do
					package:install()
				end
				vim.notify("Updating all Mason packages...", vim.log.levels.INFO)
			end,
			opts = { desc = "Update all installed Mason packages" },
		},

		MasonCleanUnused = {
			callback = function()
				local mr = require("mason-registry")
				local config = require("bearvim.configs.mason")
				local installed_packages = mr.get_installed_packages()

				for _, package in ipairs(installed_packages) do
					if
						not vim.tbl_contains(config.options.ensure_installed, package.name)
					then
						vim.ui.select(
							{ "Yes", "No" },
							{
								prompt = string.format(
									"Remove unused package '%s'?",
									package.name
								),
							},
							function(choice)
								if choice == "Yes" then
									package:uninstall()
									vim.notify(
										string.format("Uninstalled %s", package.name),
										vim.log.levels.INFO
									)
								end
							end
						)
					end
				end
			end,
			opts = { desc = "Clean unused Mason packages" },
		},
	},
})
