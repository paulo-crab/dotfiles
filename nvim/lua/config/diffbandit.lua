require("diffbandit").setup()

local open_reviewed_file = function()
	local api = vim.api
	local review_tab = api.nvim_get_current_tabpage()
	local state = require("diffbandit.state")
	local session = state.sessions[review_tab]
	local queue = session and session.file_queue

	if not queue or queue.kind ~= "git" then
		vim.notify("No Git file is selected in this DiffBandit review", vim.log.levels.WARN)
		return
	end

	local index = session.file_queue_index or queue.index or 1
	local entry = queue.entries and queue.entries[index]
	if not entry or not entry.path then
		vim.notify("No file is selected in this DiffBandit review", vim.log.levels.WARN)
		return
	end

	if not queue.root then
		vim.notify("This DiffBandit review has no repository root", vim.log.levels.ERROR)
		return
	end

	local path = vim.fs.normalize(vim.fs.joinpath(queue.root, entry.path))
	local buffer = vim.fn.bufnr(path)
	if vim.uv.fs_stat(path) == nil and (buffer < 1 or not api.nvim_buf_is_loaded(buffer)) then
		vim.notify("This file is absent from the current checkout: " .. entry.path, vim.log.levels.WARN)
		return
	end

	local tabs = api.nvim_list_tabpages()
	local alternate_tab = vim.fn.tabpagenr("#")
	local editor_tab = alternate_tab > 0 and tabs[alternate_tab] or nil
	local editor_session = editor_tab and state.sessions[editor_tab]
	if not editor_tab or editor_tab == review_tab or (editor_session and not editor_session.disposed) then
		editor_tab = nil
		for _, tab in ipairs(tabs) do
			local tab_session = state.sessions[tab]
			if tab ~= review_tab and (not tab_session or tab_session.disposed) then
				editor_tab = tab
				break
			end
		end
	end

	if not editor_tab then
		vim.notify("No regular editor tab is available", vim.log.levels.WARN)
		return
	end

	api.nvim_set_current_tabpage(editor_tab)
	local ok, err = pcall(vim.cmd, "edit " .. vim.fn.fnameescape(path))
	if not ok then
		vim.notify(tostring(err), vim.log.levels.ERROR)
	end
end

local group = vim.api.nvim_create_augroup("UserDiffBanditOpenReviewedFile", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	callback = function(event)
		local review_tab = vim.api.nvim_get_current_tabpage()
		vim.schedule(function()
			local session = require("diffbandit.state").sessions[review_tab]
			if not session or session.disposed or not session.file_queue or session.file_queue.kind ~= "git" then
				return
			end

			local ok, diffbandit = pcall(require, "diffbandit")
			if not ok or not diffbandit.is_running({ buf = event.buf }) then
				return
			end

			vim.keymap.set("n", "<leader>ge", open_reviewed_file, {
				buffer = event.buf,
				desc = "Git: Open reviewed file in editor",
			})
		end)
	end,
})
