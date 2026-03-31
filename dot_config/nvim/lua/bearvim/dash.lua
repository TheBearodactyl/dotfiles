local utils = require("bearvim.core.utils")

local uv = vim.loop
local json = vim.json
local if_nil = vim.F.if_nil

local data_dir = vim.fn.stdpath("data")
local state_file = data_dir .. "/image_state.json"

local function read_file(path)
	local fd = uv.fs_open(path, "r", 438)
	if not fd then return nil end
	local stat = uv.fs_fstat(fd)
	local data = uv.fs_read(fd, stat.size, 0)
	uv.fs_close(fd)
	return data
end

local function write_file(path, data)
	local fd = uv.fs_open(path, "w", 438)
	if not fd then return end
	uv.fs_write(fd, data, 0)
	uv.fs_close(fd)
end

local function load_state()
	local data = read_file(state_file)
	if not data or data == "" then return nil end
	local ok, decoded = pcall(json.decode, data)
	return ok and decoded or nil
end

local function save_state(state)
	write_file(state_file, json.encode(state))
end

local function image_modtimes(modules)
	local mtimes = {}
	for _, mod in ipairs(modules) do
		local path = vim.fn.stdpath("config")
			.. "/lua/"
			.. mod:gsub("%.", "/")
			.. ".lua"
		local stat = uv.fs_stat(path)
		mtimes[mod] = stat and stat.mtime.sec or 0
	end
	return mtimes
end

local function is_state_outdated(state, modules)
	if not state or not state.mtimes then return true end
	if #state.modules ~= #modules then return true end
	for _, mod in ipairs(modules) do
		if not state.mtimes[mod] then return true end
		local path = vim.fn.stdpath("config")
			.. "/lua/"
			.. mod:gsub("%.", "/")
			.. ".lua"
		local stat = uv.fs_stat(path)
		if not stat or stat.mtime.sec ~= state.mtimes[mod] then return true end
	end
	return false
end

--- @return table image_data, string module_name
local function random_image()
	local modules = utils.discover_images()
	local state = load_state()

	if is_state_outdated(state, modules) then
		state = {
			modules = vim.deepcopy(modules),
			remaining = vim.deepcopy(modules),
			mtimes = image_modtimes(modules),
		}
		save_state(state)
	end

	if not state then return {}, "" end

	if #state.remaining == 0 then state.remaining = vim.deepcopy(modules) end

	math.randomseed((uv.hrtime() % 1e6) + os.time())
	local idx = math.random(#state.remaining)
	local choice = state.remaining[idx]
	table.remove(state.remaining, idx)
	save_state(state)

	local ok, image_module = pcall(require, choice)
	if not ok or not image_module then
		return {
			name = "Error loading image",
			desc = "Failed to load module: " .. choice,
			image_str = { "Failed to load image." },
		},
			choice
	end

	if type(image_module) == "table" and image_module.image_str then
		if not image_module.name then
			image_module.name = choice:match("([%w-_]+)$")
		end
		return image_module, choice
	elseif type(image_module) == "table" then
		return {
			name = choice:match("([%w-_]+)$"),
			image_str = image_module,
			desc = "",
		},
			choice
	else
		return {
			name = choice:match("([%w-_]+)$"),
			image_str = { tostring(image_module) },
			desc = "",
		},
			choice
	end
end

local function button(sc, txt, keybind, keybind_opts)
	local leader = "SPC"
	local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")
	local opts = {
		position = "center",
		shortcut = sc,
		cursor = 3,
		width = 50,
		align_shortcut = "right",
		hl_shortcut = "Keyword",
	}
	if keybind then
		keybind_opts = if_nil(
			keybind_opts,
			{ noremap = true, silent = true, nowait = true }
		)
		opts.keymap = { "n", sc_, keybind, keybind_opts }
	end
	local function on_press()
		local key = vim.api.nvim_replace_termcodes(
			keybind or sc_ .. "<Ignore>",
			true,
			false,
			true
		)
		vim.api.nvim_feedkeys(key, "t", false)
	end
	return { type = "button", val = txt, on_press = on_press, opts = opts }
end

local function is_small_image(image_data)
	return #image_data.image_str <= 40
end

local function build_dashboard()
	local image_data, module_name = random_image()
	local small = is_small_image(image_data)

	local header = {
		type = "text",
		val = image_data.image_str,
		opts = { position = "center", hl = "Type" },
	}

	local buttons = {
		type = "group",
		val = small and {
			button("e", "  New file", "<cmd>ene <CR>"),
			button("SPC f f", "󰈞  Find file"),
			button("SPC f h", "󰊄  Recently opened files"),
			button("SPC f r", "  Frecency/MRU"),
			button("SPC f g", "󰈬  Find word"),
			button("SPC f m", "  Jump to bookmarks"),
			button("SPC s l", "  Open last session"),
		} or {},
		opts = { spacing = 1 },
	}

	local footer_text = string.format(
		"%s%s (%s) %s",
		image_data.name or "Unnamed",
		image_data.desc
				and image_data.desc ~= ""
				and (" — " .. image_data.desc)
			or "",
		module_name,
		image_data.source and ("(" .. image_data.source .. ")") or ""
	)

	local footer = {
		type = "text",
		val = footer_text,
		opts = { position = "center", hl = "Number" },
	}

	return {
		layout = {
			{ type = "padding", val = 1 },
			header,
			{ type = "padding", val = small and 1 or 2 },
			buttons,
			{ type = "padding", val = small and 1 or 2 },
			footer,
		},
		opts = { margin = small and 5 or 3 },
	}
end

local function start_watcher(callback)
	local dir = vim.fn.stdpath("config") .. "/lua/bearvim/images"
	local fs_event = uv.new_fs_event()
	if not fs_event then return end

	local debounce_timer
	fs_event:start(dir, { recursive = true }, function(err, fname, status)
		if err then return end
		if fname and fname:match("%.lua$") then
			if debounce_timer then
				debounce_timer:stop()
				debounce_timer:close()
			end
			debounce_timer = uv.new_timer()
			debounce_timer:start(500, 0, function()
				vim.schedule(function()
					if callback then callback() end
				end)
				debounce_timer:stop()
				debounce_timer:close()
			end)
		end
	end)
end

local function setup_dashboard()
	local dashboard_config = build_dashboard()
	vim.api.nvim_create_autocmd("User", {
		pattern = "AlphaReady",
		once = true,
		callback = function()
			start_watcher(function()
				vim.notify(
					"Images changed — refreshing dashboard...",
					vim.log.levels.INFO
				)
				package.loaded["bearvim.images"] = nil
				vim.cmd("AlphaRedraw")
			end)
		end,
	})
	return dashboard_config
end

return {
	config = setup_dashboard(),
	rebuild = build_dashboard,
}
