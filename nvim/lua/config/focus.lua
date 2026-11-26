require("twilight").setup({
	context = 10,
	treesitter = true,
	-- Keep the focus window limited to the configured context around the cursor.
	expand = {},
})

local M = {}
local state = {}
local api = vim.api

local diagnostic_handlers = { "signs", "underline", "virtual_text", "virtual_lines" }

local function refresh_diagnostics()
	local namespaces = vim.diagnostic.get_namespaces()
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_loaded(buf) then
			for namespace in pairs(namespaces) do
				vim.diagnostic.show(namespace, buf)
			end
		end
	end
end

local function set_focus_diagnostics(enabled)
	if enabled then
		state.diagnostic_config = vim.deepcopy(vim.diagnostic.config())
		local config = vim.deepcopy(state.diagnostic_config)
		-- Keep errors visible in focus mode; hide warnings, information, and hints.
		local visible_severities = { vim.diagnostic.severity.ERROR }

		for _, handler in ipairs(diagnostic_handlers) do
			local handler_config = config[handler]
			local enabled_by_default = handler == "signs" or handler == "underline"

			if handler_config ~= false then
				if handler_config == true or (handler_config == nil and enabled_by_default) then
					handler_config = {}
				end

				if type(handler_config) == "table" then
					handler_config.severity = visible_severities
					config[handler] = handler_config
				end
			end
		end

		local float_config = config.float
		if float_config ~= false then
			if float_config == true or float_config == nil then
				float_config = {}
			end
			if type(float_config) == "table" then
				float_config.severity = visible_severities
				config.float = float_config
			end
		end

		vim.diagnostic.config(config)
	elseif state.diagnostic_config then
		vim.diagnostic.config(state.diagnostic_config)
		state.diagnostic_config = nil
	end

	refresh_diagnostics()
end

function M.toggle()
	if state.zoom_win and api.nvim_win_is_valid(state.zoom_win) then
		local zoom_buffer = api.nvim_win_get_buf(state.zoom_win)
		local cursor = api.nvim_win_get_cursor(state.zoom_win)
		vim.cmd("Twilight")
		require("mini.misc").zoom()
		set_focus_diagnostics(false)

		if state.source_tab and api.nvim_tabpage_is_valid(state.source_tab) then
			api.nvim_set_current_tabpage(state.source_tab)
		end
		if state.source_win and api.nvim_win_is_valid(state.source_win) then
			api.nvim_set_current_win(state.source_win)
			if api.nvim_win_get_buf(state.source_win) == state.source_buf and zoom_buffer == state.source_buf then
				api.nvim_win_set_cursor(state.source_win, cursor)
			end
		end
		state = {}
		return
	end

	state.source_win = api.nvim_get_current_win()
	state.source_tab = api.nvim_get_current_tabpage()
	state.source_buf = api.nvim_get_current_buf()
	vim.cmd("Twilight")
	require("mini.misc").zoom()
	state.zoom_win = api.nvim_get_current_win()
	-- The zoomed window can inherit CursorLine from the source window; keep the
	-- focus view clean while Twilight handles dimming outside the focused code.
	vim.wo[state.zoom_win].cursorline = false
	-- MiniMisc uses a floating window, so match its Normal background to the
	-- editor's Normal group. Twilight's dimmed lines then keep the same backdrop.
	vim.wo[state.zoom_win].winhighlight = "Normal:Normal"
	set_focus_diagnostics(true)
end

return M
