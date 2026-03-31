local M = {}

--- @class ConfigModule
--- @field name? string Module name for debugging
--- @field options? table Default options
--- @field setup? fun(opts?: table): any Setup function
--- @field keys? table: table Key mappings
--- @field commands? table User commands
--- @field autocmds? table Autocommands
--- @field filetypes? string[] Filetypes this config applies to

--- Create a configuration module
--- @param config ConfigModule
--- @return ConfigModule
function M.create(config)
	if not config or type(config) ~= "table" then
		error("Config must be a table", 2)
	end

	local module = vim.tbl_deep_extend("force", {}, config)
	local module_name = config.name or "unnamed"

	if config.setup then
		module.setup = function(opts)
			local success, result = pcall(function()
				opts = vim.tbl_deep_extend(
					"force",
					config.options or {},
					opts or {}
				)

				if config.autocmds then
					M._setup_autocmds(config.autocmds, module_name)
				end

				if config.commands then
					M._setup_commands(config.commands, module_name)
				end

				local setup_result = config.setup(opts)

				local keys = type(config.keys) == "function"
						and config.keys(opts)
					or config.keys
				if keys then M._register_keys(keys) end

				return setup_result
			end)

			if not success then
				vim.notify(
					string.format("Error in %s setup: %s", module_name, result),
					vim.log.levels.ERROR
				)
				return nil
			end

			return result
		end
	else
		module.setup = function(opts)
			opts = opts or {}
			local keys = type(config.keys) == "function" and config.keys(opts)
				or config.keys
			if keys then M._register_keys(keys) end
		end
	end

	return module
end

--- @class RegexOpts Regex command options
--- @field name string Command name (will be prefixed with user command prefix)
--- @field match string Pattern to match
--- @field replace string Replacement pattern
--- @field range? string Range (default: "%")
--- @field flags? string Additional flags (default: "")
--- @field global? boolean Add 'g' flag (default: false)
--- @field confirm? boolean Add 'c' flag for confirmation (default: false)
--- @field desc? string Command description

--- Helper for creating regex substitution commands
--- @param opts RegexOpts Command options
--- @return table Command configuration
function M.regex(opts)
	if type(opts) ~= "table" then
		error("regex() requires a table argument", 2)
	end

	if type(opts.name) ~= "string" or opts.name == "" then
		error("regex() requires a non-empty 'name' field", 2)
	end

	if type(opts.match) ~= "string" or opts.match == "" then
		error("regex() requires a non-empty 'match' field", 2)
	end

	if type(opts.replace) ~= "string" then
		error("regex() requires a 'replace' field", 2)
	end

	local range = opts.range or "%"
	local flags = opts.flags or ""

	if opts.global and not flags:match("g") then flags = flags .. "g" end

	if opts.confirm and not flags:match("c") then flags = flags .. "c" end

	local escaped_match = opts.match:gsub("/", "\\/")
	local escaped_replace = opts.replace:gsub("/", "\\/")

	return {
		name = "RgxSub" .. opts.name,
		command = function()
			local cmd_str = range
				.. "s/"
				.. escaped_match
				.. "/"
				.. escaped_replace
				.. "/"
				.. flags
			vim.cmd(cmd_str)
		end,
		desc = opts.desc
			or string.format("Regex: %s -> %s", opts.match, opts.replace),
		range = range ~= "%" and true or nil,
	}
end

--- @class AliasOpts
--- @field name string Command name
--- @field command string|function Command to execute
--- @field desc? string Command description
--- @field range? boolean|number Accept range
--- @field nargs? string|number Number of arguments
--- @field complete? string|function Completion function
--- @field bang? boolean Accept bang modifier

--- Helper for creating simple command aliases
--- @param opts AliasOpts Command options
--- @return table Command configuration
function M.alias(opts)
	if type(opts) ~= "table" then
		error("alias() requires a table argument", 2)
	end

	if type(opts.name) ~= "string" or opts.name == "" then
		error("alias() requires a non-empty 'name' field", 2)
	end

	if not opts.command then error("alias() requires a 'command' field", 2) end

	return {
		name = opts.name,
		command = opts.command,
		desc = opts.desc or string.format("Alias: %s", opts.name),
		range = opts.range,
		nargs = opts.nargs,
		complete = opts.complete,
		bang = opts.bang,
	}
end

--- Helper for creating a generic command
--- @param name string Command name
--- @param callback string|function Command callback
--- @param opts? table Additional options
--- @return table Command configuration
function M.command(name, callback, opts)
	if type(name) ~= "string" or name == "" then
		error("command() requires a non-empty name", 2)
	end

	if not callback then error("command() requires a callback", 2) end

	opts = opts or {}

	return vim.tbl_extend("force", {
		name = name,
		command = callback,
	}, opts)
end

--- Register a single command
--- @param cmd_config table Command configuration
function M.register_command(cmd_config)
	if type(cmd_config) ~= "table" then
		vim.notify("Command config must be a table", vim.log.levels.WARN)
		return
	end

	local name = cmd_config.name
	local command = cmd_config.command

	if type(name) ~= "string" or name == "" then
		vim.notify("Command must have a valid name", vim.log.levels.WARN)
		return
	end

	if not command then
		vim.notify(
			string.format("Command '%s' must have a command or callback", name),
			vim.log.levels.WARN
		)
		return
	end

	local cmd_opts = {
		desc = cmd_config.desc,
		range = cmd_config.range,
		nargs = cmd_config.nargs or 0,
		complete = cmd_config.complete,
		bang = cmd_config.bang,
	}

	local success, err = pcall(function()
		vim.api.nvim_create_user_command(name, command, cmd_opts)
	end)

	if not success then
		vim.notify(
			string.format("Failed to create command '%s': %s", name, err),
			vim.log.levels.WARN
		)
	end
end

--- Setup autocommands
--- @param autocmds table
--- @param module_name string
function M._setup_autocmds(autocmds, module_name)
	if not autocmds or type(autocmds) ~= "table" then return end

	local augroup =
		vim.api.nvim_create_augroup("config_" .. module_name, { clear = true })

	for i, autocmd in ipairs(autocmds) do
		local success, err = pcall(function()
			local autocmd_opts = vim.tbl_deep_extend("force", {}, autocmd)
			autocmd_opts.group = autocmd_opts.group or augroup

			local events = autocmd_opts.event
			autocmd_opts.event = nil

			if not events then error("Autocmd must have an event") end

			vim.api.nvim_create_autocmd(events, autocmd_opts)
		end)

		if not success then
			vim.notify(
				string.format(
					"Error creating autocmd %d in %s: %s",
					i,
					module_name,
					err
				),
				vim.log.levels.WARN
			)
		end
	end
end

--- Setup commands
--- @param commands table
--- @param module_name string
function M._setup_commands(commands, module_name)
	if not commands or type(commands) ~= "table" then return end

	for name, command in pairs(commands) do
		local success, err = pcall(function()
			if type(name) ~= "string" or name == "" then
				error("Command name must be a non-empty string")
			end

			local callback = command.callback or command[1]
			local opts = command.opts or {}

			if not callback then error("Command must have a callback") end

			vim.api.nvim_create_user_command(name, callback, opts)
		end)

		if not success then
			vim.notify(
				string.format(
					"Error creating command '%s' in %s: %s",
					name,
					module_name,
					err
				),
				vim.log.levels.WARN
			)
		end
	end
end

--- Register keys
--- @param keys table
function M._register_keys(keys)
	if not keys or type(keys) ~= "table" then return end

	vim.schedule(function()
		local success, keys_module = pcall(require, "bearvim.core.keys")
		if success and keys_module and keys_module.register then
			keys_module.register(keys)
		else
			vim.notify("Failed to load keys module", vim.log.levels.WARN)
		end
	end)
end

--- Helper for conditional configuration with enhanced validation
--- @param condition boolean|fun(): boolean
--- @param config table
--- @return table|nil
function M.when(condition, config)
	if config == nil then return nil end

	local should_include = false

	if type(condition) == "function" then
		local success, result = pcall(condition)
		should_include = success and result
	else
		should_include = not not condition
	end

	return should_include and config or nil
end

--- Helper for filetype-specific configuration with validation
--- @param filetypes string|string[]
--- @param config table
--- @return table
function M.filetype(filetypes, config)
	if not config then error("Config cannot be nil", 2) end

	if type(filetypes) == "string" then
		filetypes = { filetypes }
	elseif not vim.islist(filetypes) then
		error("Filetypes must be a string or list of strings", 2)
	end

	for _, ft in ipairs(filetypes) do
		if type(ft) ~= "string" or ft == "" then
			error("Each filetype must be a non-empty string", 2)
		end
	end

	local result = vim.deepcopy(config)
	result.ft = filetypes
	return result
end

return M
