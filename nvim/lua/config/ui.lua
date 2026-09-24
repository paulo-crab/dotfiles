local M = {}

-- Shared window highlights for blink.cmp. Its content and behavior stay in
-- config.completion; only its presentation lives here.
M.blink = {
	menu = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None,CurSearch:None",
	documentation = "Normal:NormalFloat,FloatBorder:FloatBorder,EndOfBuffer:NormalFloat",
	signature = "Normal:NormalFloat,FloatBorder:FloatBorder",
}

local function apply_highlights()
	-- A TUI cursor uses the highlight background for its color. DiagnosticInfo
	-- provides an accent in both light and dark themes without a fixed palette.
	local info = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo", link = false })
	vim.api.nvim_set_hl(0, "InsertCursor", { fg = "bg", bg = info.fg or "fg" })

	-- Light themes can use the softer statusline surface for the block cursor;
	-- invert Normal on dark themes where that surface can blend into the buffer.
	if vim.o.background == "light" then
		vim.api.nvim_set_hl(0, "Cursor", { link = "StatusLine" })
	else
		vim.api.nvim_set_hl(0, "Cursor", { fg = "bg", bg = "fg" })
	end
	vim.api.nvim_set_hl(0, "TermCursor", { link = "Cursor" })

	-- Use the theme's selected-menu treatment for the active buffer tab.
	-- Modified tabs retain their theme-provided warning/modified styling.
	vim.api.nvim_set_hl(0, "MiniTablineCurrent", { link = "PmenuSel" })

	-- Keep the current search match visible without adding another accent color.
	vim.api.nvim_set_hl(0, "CurSearch", { link = "IncSearch" })

	-- FFF ships fixed Git colors. Link its groups to the active theme instead.
	local git_groups = {
		Staged = "DiagnosticOk",
		Modified = "DiagnosticWarn",
		Deleted = "DiagnosticError",
		Renamed = "DiagnosticInfo",
		Untracked = "DiagnosticOk",
		Ignored = "Comment",
	}

	for status, target in pairs(git_groups) do
		vim.api.nvim_set_hl(0, "FFFGit" .. status, { link = target })
		vim.api.nvim_set_hl(0, "FFFGitSign" .. status, { link = target })
		vim.api.nvim_set_hl(0, "FFFGitSign" .. status .. "Selected", { link = target })
	end

	vim.api.nvim_set_hl(0, "FFFSelected", { link = "Directory" })
	vim.api.nvim_set_hl(0, "FFFSelectedActive", { link = "Visual" })
end

local function setup_statusline()
	local statusline = require("mini.statusline")

	local function filename_section()
		if vim.bo.filetype == "NvimTree" then
			return " 󰙅 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
		end

		return statusline.section_filename({ trunc_width = 140 })
	end

	statusline.setup({
		content = {
			active = function()
				local neovim_icon = ""
				local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
				local git = statusline.section_git({ trunc_width = 40 })
				local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
				local filename = filename_section()
				local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
				local location = statusline.section_location({ trunc_width = 75 })

				local mode_icons = {
					Normal = "󰆾",
					Insert = "󰏫",
					Visual = "󰒉",
					["V-Line"] = "󰒉",
					["V-Block"] = "󰒉",
					Replace = "󰛔",
					Command = "󰘳",
					Terminal = "󰆍",
				}

				local icon = mode_icons[vim.trim(mode)] or "󰘳"
				mode = icon .. " " .. mode

				return statusline.combine_groups({
					{ hl = mode_hl, strings = { neovim_icon, mode } },
					{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
					"%<",
					{ hl = "MiniStatuslineFilename", strings = { filename } },
					"%=",
					{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
					{ hl = mode_hl, strings = { location } },
				})
			end,
		},
	})
end

local function setup_tabline()
	require("mini.tabline").setup({ show_icons = false, tabpage_section = "right" })

	local function refresh_tabline()
		local file_buffers = 0
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
				file_buffers = file_buffers + 1
				if file_buffers > 1 then break end
			end
		end

		vim.o.showtabline = (file_buffers > 1 or #vim.api.nvim_list_tabpages() > 1) and 2 or 0
	end

	local group = vim.api.nvim_create_augroup("ConfigUiTabline", { clear = true })
	vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufEnter", "TabEnter", "TabClosed" }, {
		group = group,
		callback = function() vim.schedule(refresh_tabline) end,
	})
	refresh_tabline()
end

function M.setup()
	-- Keep Insert mode's bar shape, with a little more width and no blinking.
	vim.opt.guicursor = table.concat({
		"n-v-c:block-Cursor",
		"i-ci-ve:ver35-InsertCursor",
		"r-cr:hor20-Cursor",
		"o:hor50-Cursor",
		"a:blinkon0",
	}, ",")

	vim.o.winborder = "rounded"
	vim.o.pumborder = "rounded"
	vim.opt.fillchars:append({ vert = "│" })

	require("mini.notify").setup({ window = { winblend = 0 } })
	setup_statusline()
	setup_tabline()

	local group = vim.api.nvim_create_augroup("ConfigUiHighlights", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			apply_highlights()
			-- A background change can load another scheme inside ColorScheme;
			-- reapply once that nested switch has finished.
			vim.schedule(apply_highlights)
		end,
	})
	apply_highlights()
end

return M
