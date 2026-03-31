---@class PluginSpec
---@field [1] string Plugin name/url
---@field name? string Plugin name
---@field dev? boolean Use local plugin
---@field lazy? boolean Enable lazy loading
---@field enabled? boolean|fun():boolean Enable/disable plugin
---@field cond? boolean|fun():boolean Conditional loading
---@field dependencies? string|string[]|PluginSpec[] Plugin dependencies
---@field init? fun(LazyPlugin) Initialization function
---@field opts? table|fun(LazyPlugin, opts: table): table Plugin options
---@field config? fun(LazyPlugin, opts: table) Configuration function
---@field main? string Main module to load
---@field build? string|fun(LazyPlugin) Build command
---@field branch? string Git branch
---@field tag? string Git tag
---@field commit? string Git commit
---@field version? string Version
---@field pin? boolean Pin plugin version
---@field submodules? boolean Include git submodules
---@field event? string|string[] Lazy loading events
---@field cmd? string|string[] Lazy loading commands
---@field ft? string|string[] Lazy loading filetypes
---@field keys? string|string[]|LazyKeys[] Lazy loading keymaps
---@field module? false Disable automatic module loading
---@field priority? number Loading priority

local M = {}

---Create a plugin specification with enhanced functionality
---@param spec PluginSpec
---@return PluginSpec
function M.spec(spec)
	if spec.config or spec.main then return spec end

	if spec.setup and not spec.config then
		local setup_fn = spec.setup
		spec.config = function(_, opts)
			setup_fn(opts or {})
		end
		spec.setup = nil
	end

	if spec.opts and not spec.config and not spec.main then
		local plugin_name = spec.name
			or spec[1]:match("([^/]+)$"):gsub("%.nvim$", ""):gsub("^nvim%-", "")
		local config_path = "configs." .. plugin_name:gsub("%-", "_")

		spec.config = function(_, opts)
			local ok, config_module = pcall(require, config_path)
			if ok and config_module then
				if type(config_module.setup) == "function" then
					config_module.setup(opts)
					return
				elseif type(config_module) == "function" then
					config_module(opts)
					return
				end
			end

			local plugin_ok, plugin_module = pcall(require, plugin_name)
			if plugin_ok and plugin_module then
				if type(plugin_module.setup) == "function" then
					plugin_module.setup(opts)
				elseif
					type(plugin_module) == "table" and plugin_module.config
				then
					if type(plugin_module.config) == "function" then
						plugin_module.config(opts)
					end
				end
			end
		end
	end

	return spec
end

---Create a language server plugin spec
---@param name string LSP server name
---@param opts? table Server configuration
---@return PluginSpec
function M.lsp(name, opts)
	return M.spec({
		"neovim/nvim-lspconfig",
		ft = opts and opts.filetypes or nil,
		opts = function(_, plugin_opts)
			plugin_opts = plugin_opts or {}
			plugin_opts.servers = plugin_opts.servers or {}
			plugin_opts.servers[name] = opts or {}
			return plugin_opts
		end,
	})
end

---Create a which-key specification
---@param mappings table Key mappings
---@return table
function M.keys(mappings)
	local keys = {}

	for key, mapping in pairs(mappings) do
		if type(mapping) == "table" then
			if mapping.group then
				table.insert(
					keys,
					{ key, group = mapping.group, cond = mapping.cond }
				)
			else
				table.insert(keys, {
					key,
					mapping[1] or mapping.cmd or mapping.callback,
					desc = mapping.desc or mapping[2],
					mode = mapping.mode,
					cond = mapping.cond,
					silent = mapping.silent,
					noremap = mapping.noremap,
				})
			end
		else
			table.insert(keys, { key, mapping })
		end
	end

	return keys
end

return M
