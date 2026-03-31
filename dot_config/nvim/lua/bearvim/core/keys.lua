local M = {}

--- @class KeySpec
--- @field [1] string Key combination
--- @field [2]? string|fun()|fun():string Command or function
--- @field desc? string Description
--- @field mode? string|string[] Mode(s)
--- @field cond? boolean|fun(): boolean Condition
--- @field group? string Group name for which-key
--- @field buffer? number Buffer-local mapping
--- @field silent? boolean Silent mapping
--- @field noremap? boolean No-remap mapping
--- @field expr? boolean Expression mapping
--- @field icon? string|table Icon specification
--- @field hidden? boolean Hide the mapping
--- @field proxy? string Proxy to another mapping
--- @field expand? fun(): KeySpec[] Dynamic nested mappings

local which_key_specs = {}
local initialized = false

--- Initialize the keys module
function M.init()
	if initialized then return end
	initialized = true

	vim.schedule(function()
		local success, wk = pcall(require, "which-key")
		if success and wk.add and #which_key_specs > 0 then
			local valid_specs = vim.tbl_filter(function(spec)
				return M._validate_keyspec(spec)
			end, which_key_specs)

			if #valid_specs > 0 then wk.add(valid_specs) end
		end
	end)
end

--- Validate a key specification
--- @param spec KeySpec
--- @return boolean
function M._validate_keyspec(spec)
	if type(spec) ~= "table" then return false end

	if type(spec[1]) ~= "string" or spec[1] == "" then
		vim.notify(
			"Invalid key: must be a non-empty string",
			vim.log.levels.WARN
		)
		return false
	end

	return true
end

--- Register keys with support for nested subgroups
--- @param keys KeySpec[]
function M.register(keys)
	if not keys or type(keys) ~= "table" then
		vim.notify("Keys must be a table", vim.log.levels.WARN)
		return
	end

	local valid_keys = {}

	for i, key in ipairs(keys) do
		if M._validate_keyspec(key) then
			if key.cond ~= nil then
				local should_include = false
				if type(key.cond) == "function" then
					local success, result = pcall(key.cond)
					should_include = success and result
				else
					should_include = not not key.cond
				end

				if not should_include then goto continue end
			end

			table.insert(valid_keys, key)
			table.insert(which_key_specs, key)

			local success, wk = pcall(require, "which-key")
			if success and wk.add then wk.add({ key }) end
		else
			vim.notify(
				string.format("Invalid key specification at index %d", i),
				vim.log.levels.WARN
			)
		end

		::continue::
	end
end

--- Get all registered which-key specs
--- @return table
function M.get_which_key_specs()
	return vim.deepcopy(which_key_specs)
end

--- Create a key group (supports nested subgroups)
--- @param prefix string Key prefix
--- @param name string Group name
--- @param opts? table Additional options (cond, icon, etc.)
--- @return KeySpec
function M.group(prefix, name, opts)
	if type(prefix) ~= "string" or prefix == "" then
		error("Prefix must be a non-empty string", 2)
	end
	if type(name) ~= "string" or name == "" then
		error("Name must be a non-empty string", 2)
	end

	opts = opts or {}

	local group_spec = { prefix, group = name }

	for key, value in pairs(opts) do
		if key ~= "group" then group_spec[key] = value end
	end

	return group_spec
end

--- Create nested subgroups with automatic hierarchy
--- @param base_prefix string Base key prefix (e.g., "<leader>g")
--- @param config table Configuration with nested structure
--- @return KeySpec[]
function M.subgroups(base_prefix, config)
	if type(base_prefix) ~= "string" or base_prefix == "" then
		error("Base prefix must be a non-empty string", 2)
	end
	if type(config) ~= "table" then error("Config must be a table", 2) end

	local function build_specs(prefix, cfg, specs)
		specs = specs or {}

		for key, value in pairs(cfg) do
			if type(value) == "table" then
				local full_prefix = prefix .. key

				local group_spec = {
					full_prefix,
					group = value.name or key:upper(),
				}

				if value.desc then group_spec.desc = value.desc end
				if value.icon then group_spec.icon = value.icon end
				if value.cond then group_spec.cond = value.cond end
				if value.mode then group_spec.mode = value.mode end

				table.insert(specs, group_spec)

				if value.subgroups then
					build_specs(full_prefix, value.subgroups, specs)
				end

				if value.mappings then
					for _, mapping in ipairs(value.mappings) do
						local mapping_spec = vim.deepcopy(mapping)
						mapping_spec[1] = full_prefix .. mapping_spec[1]
						table.insert(specs, mapping_spec)
					end
				end
			end
		end

		return specs
	end

	return build_specs(base_prefix, config)
end

--- Create buffer-local key mappings
--- @param keys KeySpec[]
--- @param buffer number Buffer number
function M.buffer(keys, buffer)
	if not keys or type(keys) ~= "table" then
		vim.notify("Keys must be a table", vim.log.levels.WARN)
		return
	end

	if type(buffer) ~= "number" or buffer < 0 then
		vim.notify("Buffer must be a valid buffer number", vim.log.levels.WARN)
		return
	end

	for i, key in ipairs(keys) do
		local success, err = pcall(function()
			if not M._validate_keyspec(key) then
				error("Invalid key specification")
			end

			local opts = {
				buffer = buffer,
				desc = key.desc,
				silent = key.silent ~= false,
				noremap = key.noremap ~= false,
				expr = key.expr or false,
			}

			local mode = key.mode or "n"
			local cmd = key[2] or key.callback or key.cmd

			if not cmd then error("Key must have a command or callback") end

			local modes = type(mode) == "string" and { mode } or mode

			for _, m in ipairs(modes) do
				vim.keymap.set(m, key[1], cmd, opts)
			end
		end)

		if not success then
			vim.notify(
				string.format("Error setting buffer key %d: %s", i, err),
				vim.log.levels.WARN
			)
		end
	end
end

--- Utility for LSP key mappings with validation
--- @param event table LSP attach event
--- @return fun(keys: KeySpec[])
function M.lsp(event)
	if not event or type(event.buf) ~= "number" then
		error("Invalid LSP event: must have a valid buffer number", 2)
	end

	return function(keys)
		M.buffer(keys, event.buf)
	end
end

--- Create hierarchical key structure for complex nested groups
--- @param structure table Nested table defining the key hierarchy
--- @param base_prefix? string Optional base prefix for all keys
--- @return KeySpec[]
function M.hierarchy(structure, base_prefix)
	base_prefix = base_prefix or ""
	local specs = {}

	local function process_level(level, prefix)
		for key, value in pairs(level) do
			local current_prefix = prefix .. key

			if value.group then
				local group_spec = {
					current_prefix,
					group = value.group,
				}

				for prop, val in pairs(value) do
					if
						prop ~= "group"
						and prop ~= "children"
						and prop ~= "mappings"
					then
						group_spec[prop] = val
					end
				end

				table.insert(specs, group_spec)

				if value.children then
					process_level(value.children, current_prefix)
				end

				if value.mappings then
					for _, mapping in ipairs(value.mappings) do
						local mapping_spec = vim.deepcopy(mapping)
						mapping_spec[1] = current_prefix .. mapping_spec[1]
						table.insert(specs, mapping_spec)
					end
				end
			else
				local mapping_spec = vim.deepcopy(value)
				mapping_spec[1] = current_prefix
				table.insert(specs, mapping_spec)
			end
		end
	end

	process_level(structure, base_prefix)
	return specs
end

--- Clear all registered specs
function M.clear()
	which_key_specs = {}
	initialized = false
end

M.init()

return M
