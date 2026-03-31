--- @diagnostic disable: undefined-field

--- @class JsonUtils.WriteOpts
--- @field indent? integer Number of spaces for indentation (default: 2)
--- @field pretty? boolean Prettify with indentation (default: true)

--- @class JsonUtils.ReadOpts
--- @field default? any Default value to return if file doesn't exist or is invalid

---@class WatchOptions
---@field recursive? boolean Watch directory recursively (default: true)
---@field pattern? string Lua pattern to filter files (default: "%.lua$")
---@field debounce_ms? integer Debounce delay in milliseconds (default: 500)
---@field on_change fun(path: string, event: string): nil Callback when file changes

---@class Watcher
---@field stop fun(): nil Stop watching and cleanup resources
---@field is_active fun(): boolean Check if watcher is still active

--- @class BearvimUtils
--- @field is_rust fun(): boolean Get whether the current buffer is Rust code
--- @field discover_specs fun(): table<string> Return an array of plugin spec definitions in the plugins directory
--- @field discover_images fun(): table<string> Return an array of available image modules for the dashboard
--- @field discover_commands fun(): table<string> Return an array of command module paths in the commands directory
--- @field save_data fun(filename: string, data: any, opts?: JsonUtils.WriteOpts): boolean, string? Save data to a given JSON file in vim.fn.stdpath("data")
--- @field load_data fun(filename: string, opts?: JsonUtils.ReadOpts): any?, string? Load data from a given JSON file in vim.fn.stdpath("data")
--- @field watch fun(path: string, opts: WatchOptions): Watcher|nil, string? Start watching a path for changes
local M = {}

--- Return whether the given string ends with <suffix>
--- @param self string The string to check for the suffix of
--- @param suffix string The suffix to search for
--- @return boolean matches Whether the string has the given suffix
function string:endswith(suffix)
	return self:sub(-#suffix) == suffix
end

--- Return whether the current buffer is Rust code
--- @return boolean is_rust
M.is_rust = function()
	return vim.bo.filetype == "rust"
end

--- Return an array of command module paths in the commands directory
--- @return table<string> command_files The array of discovered command modules
M.discover_commands = function()
	local command_files = {}
	local base_path = vim.fn.stdpath("config") .. "/lua/bearvim/commands"

	local function find_command_files(path)
		local handle = vim.loop.fs_scandir(path)
		if not handle then return end

		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then break end

			local full_path = path .. "/" .. name

			if type == "directory" then
				find_command_files(full_path)
			elseif type == "file" and name:match(".*%.lua$") then
				local import_path = full_path
					:gsub(".*/lua/", "")
					:gsub("%.lua$", "")
					:gsub("/", ".")
				table.insert(command_files, import_path)
			end
		end
	end

	if vim.loop.fs_stat(base_path) then find_command_files(base_path) end

	return command_files
end

--- Return an array of plugin spec definitions in the plugins directory
--- @return table<string> spec_files The array of discovered plugin specs
M.discover_specs = function()
	local spec_files = {}
	local base_path = vim.fn.stdpath("config") .. "/lua/bearvim/plugins"

	local function find_spec_files(path)
		--- @diagnostic disable-next-line: undefined-field
		local handle = vim.loop.fs_scandir(path)
		if not handle then return end

		while true do
			--- @diagnostic disable-next-line: undefined-field
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then break end

			local full_path = path .. "/" .. name

			if type == "directory" then
				find_spec_files(full_path)
			elseif type == "file" and name:match(".*%.lua$") then
				local import_path = full_path
					:gsub(".*/lua/", "")
					:gsub("%.lua$", "")
					:gsub("/", ".")
				table.insert(spec_files, { import = import_path })
			end
		end
	end

	--- @diagnostic disable-next-line: undefined-field
	if vim.loop.fs_stat(base_path) then find_spec_files(base_path) end

	return spec_files
end

--- Get an array of available image modules for display on the dashboard
--- @return table<string> modules The list of available dashboard image modules
M.discover_images = function()
	local base = vim.fn.stdpath("config") .. "/lua/bearvim/images"
	local modules = {}

	local function scan_dir(dir)
		for name, type_ in vim.fs.dir(dir) do
			local full = dir .. "/" .. name
			if type_ == "file" and name:match("%.lua$") then
				local rel = full:gsub("^.+[\\/]lua[\\/]", ""):gsub("%.lua$", "")
				local module_name = rel:gsub("[\\/]", ".")
				table.insert(modules, module_name)
			elseif type_ == "directory" then
				scan_dir(full)
			end
		end
	end

	scan_dir(base)
	table.sort(modules)
	return modules
end

--- Get the full path to a JSON file in the data directory
--- @param filename string The name of the JSON file
--- @return string file_path Full path to the file
local function get_data_path(filename)
	local data_dir = vim.fn.stdpath("data")
	return vim.fs.joinpath(data_dir, filename)
end

--- Format a JSON string with a given number of spaces to indent by
--- @param json string The JSON string to format
--- @param indent integer The number of spaces to indent by (default: 2)
--- @return string formatted The formatted version of the given JSON
local function prettify_json(json, indent)
	local result = {}
	local level = 0
	local in_string = false
	local escape_next = false

	for i = 1, #json do
		local char = json:sub(i, i)

		if escape_next then
			table.insert(result, char)
			escape_next = false
		elseif char == "\\" and in_string then
			table.insert(result, char)
			escape_next = true
		elseif char == "\"" then
			table.insert(result, char)
			in_string = not in_string
		elseif not in_string then
			if char == "{" or char == "[" then
				table.insert(result, char)
				level = level + 1
				table.insert(result, "\n" .. string.rep(" ", level * indent))
			elseif char == "}" or char == "]" then
				level = level - 1
				table.insert(result, "\n" .. string.rep(" ", level * indent))
				table.insert(result, char)
			elseif char == "," then
				table.insert(result, char)
				table.insert(result, "\n" .. string.rep(" ", level * indent))
			elseif char == ":" then
				table.insert(result, char)
				table.insert(result, " ")
			elseif char ~= " " and char ~= "\n" and char ~= "\t" then
				table.insert(result, char)
			end
		else
			table.insert(result, char)
		end
	end

	return table.concat(result)
end

--- Save some Lua data as a JSON file in vim.fn.stdpath("data")
--- @param filename string The name of the file
--- @param data any The Lua data to save as a JSON file
--- @param opts? JsonUtils.WriteOpts Optional settings
--- @return boolean success Whether the save was successful
--- @return string? error Error message if save failed
M.save_data = function(filename, data, opts)
	opts = opts or {}
	local pretty = opts.pretty ~= false
	local indent = opts.indent or 2

	if type(filename) ~= "string" or filename == "" then
		return false, "filename must be a non-empty string"
	end

	local filepath = get_data_path(filename)

	local ok, json_str = pcall(vim.json.encode, data)
	if not ok then
		return false, "Failed to encode data to JSON: " .. tostring(json_str)
	end

	if pretty then json_str = prettify_json(json_str, indent) end

	local dir = vim.fs.dirname(filepath)
	--- @diagnostic disable-next-line: undefined-field
	if not vim.uv.fs_stat(dir) then
		local mkdir_ok, mkdir_err = pcall(vim.fn.mkdir, dir, "p")
		if not mkdir_ok then
			return false, "Failed to create directory: " .. tostring(mkdir_err)
		end
	end

	local file, err = io.open(filepath, "w")
	if not file then
		return false, "Failed to open file for writing: " .. tostring(err)
	end

	local write_ok, write_err = file:write(json_str)
	file:close()

	if not write_ok then
		return false, "Failed to write to file: " .. tostring(write_err)
	end

	return true
end

--- Load some data from a JSON file in vim.fn.stdpath("data")
--- @param filename string The name of the file (e.g., "mydata.json")
--- @param opts? JsonUtils.ReadOpts Optional settings
--- @return any? data The decoded Lua table/value, or nil if failed
--- @return string? error Error message if load failed
M.load_data = function(filename, opts)
	opts = opts or {}

	if type(filename) ~= "string" or filename == "" then
		return opts.default, "filename must be a non-empty string"
	end

	local filepath = get_data_path(filename)

	--- @diagnostic disable-next-line: undefined-field
	if not vim.uv.fs_stat(filepath) then
		if opts.default ~= nil then return opts.default, nil end
		return nil, "File does not exist: " .. filepath
	end

	local file, err = io.open(filepath, "r")
	if not file then
		return opts.default,
			"Failed to open file for reading: " .. tostring(err)
	end

	local content = file:read("*all")
	file:close()

	if not content or content == "" then
		return opts.default, "File is empty"
	end

	local ok, data = pcall(vim.json.decode, content)
	if not ok then
		return opts.default, "Failed to decode JSON: " .. tostring(data)
	end

	return data
end

--- @param path string Path to watch (file or directory)
--- @param opts WatchOptions Options for watching
--- @return Watcher|nil watcher Watcher object, or nil if failed to start
--- @return string? error Error message if failed
M.watch = function(path, opts)
	local uv = vim.uv

	if type(path) ~= "string" or path == "" then
		return nil, "path must be a non-empty string"
	end

	if type(opts) ~= "table" or type(opts.on_change) ~= "function" then
		return nil, "opts.on_change must be a function"
	end

	local recursive = opts.recursive ~= false
	local pattern = opts.pattern or "%.lua$"
	local debounce_ms = opts.debounce_ms or 500
	local callback = opts.on_change

	path = vim.fs.normalize(path)

	if not uv.fs_stat(path) then return nil, "Path does not exist: " .. path end

	local fs_event = uv.new_fs_event()
	if not fs_event then return nil, "Failed to create fs_event handle" end

	local debounce_timer = nil
	local is_active = true

	local ok, err = pcall(function()
		fs_event:start(
			path,
			{ recursive = recursive },
			function(err, fname, status)
				if err then return end
				if fname and not fname:match(pattern) then return end

				if debounce_timer then
					debounce_timer:stop()
					debounce_timer:close()
				end

				debounce_timer = uv.new_timer()
				if not debounce_timer then return end

				debounce_timer:start(debounce_ms, 0, function()
					vim.schedule(function()
						if is_active and callback then
							local changed_path = fname
									and vim.fs.joinpath(path, fname)
								or path
							callback(
								changed_path,
								status.change and "change" or "rename"
							)
						end
					end)

					if debounce_timer then
						debounce_timer:stop()
						debounce_timer:close()
						debounce_timer = nil
					end
				end)
			end
		)
	end)

	if not ok then
		fs_event:close()
		return nil, "failed to start watching: " .. tostring(err)
	end

	return {
		stop = function()
			is_active = false

			if fs_event and not fs_event:is_closing() then
				fs_event:stop()
				fs_event:close()
			end

			if debounce_timer then
				debounce_timer:stop()
				debounce_timer:close()
				debounce_timer = nil
			end
		end,

		is_active = function()
			return is_active and fs_event and not fs_event:is_closing()
		end,
	}
end

return M
