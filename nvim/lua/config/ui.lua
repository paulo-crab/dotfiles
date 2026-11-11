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
	local git_root_cache = {}

	local function git_root(path)
		local directory = vim.fs.dirname(path)
		if git_root_cache[directory] ~= nil then
			return git_root_cache[directory] or nil
		end

		local root = vim.fs.root(directory, ".git")
		git_root_cache[directory] = root or false
		return root
	end

	local function take_prefix(text, max_width)
		local result, width = {}, 0
		for index = 0, vim.fn.strchars(text) - 1 do
			local char = vim.fn.strcharpart(text, index, 1)
			local char_width = vim.fn.strdisplaywidth(char)
			if width + char_width > max_width then
				break
			end
			table.insert(result, char)
			width = width + char_width
		end
		return table.concat(result)
	end

	local function take_suffix(text, max_width)
		local result, width = {}, 0
		for index = vim.fn.strchars(text) - 1, 0, -1 do
			local char = vim.fn.strcharpart(text, index, 1)
			local char_width = vim.fn.strdisplaywidth(char)
			if width + char_width > max_width then
				break
			end
			table.insert(result, 1, char)
			width = width + char_width
		end
		return table.concat(result)
	end

	local function truncate_middle(text, max_width)
		if vim.fn.strdisplaywidth(text) <= max_width then
			return text
		end

		local ellipsis = "…"
		local remaining_width = max_width - vim.fn.strdisplaywidth(ellipsis)
		if remaining_width <= 0 then
			return take_prefix(text, max_width)
		end

		local left_width = math.floor(remaining_width / 2)
		return take_prefix(text, left_width)
			.. ellipsis
			.. take_suffix(text, remaining_width - left_width)
	end

	local function shorten_git(git)
		local max_width = 42
		if vim.fn.strdisplaywidth(git) <= max_width then
			return git
		end

		local icon, branch = git:match("^(%S+)%s+(.+)$")
		if icon == nil then
			return truncate_middle(git, max_width)
		end

		local branch_width = max_width - vim.fn.strdisplaywidth(icon) - 1
		local prefix = branch:match("^([^/]+/[^/]+/)")
		local omitted = "…/"
		if prefix ~= nil then
			local suffix_width = branch_width
				- vim.fn.strdisplaywidth(prefix)
				- vim.fn.strdisplaywidth(omitted)
			if suffix_width > 0 then
				local suffix = take_suffix(branch, suffix_width)
				suffix = suffix:match("^[^%-%_/]+[-_/](.+)$") or suffix
				return icon .. " " .. prefix .. omitted .. suffix
			end
		end

		return icon .. " " .. truncate_middle(branch, branch_width)
	end

	local function escape_statusline(text)
		return text:gsub("%%", "%%%%")
	end

	local function filename_section()
		if vim.bo.filetype == "NvimTree" then
			local cwd = vim.fn.getcwd()
			local root = vim.fs.root(cwd, ".git") or cwd
			local project_name = vim.fn.fnamemodify(root, ":t")
			return " 󰙅 " .. (project_name ~= "" and project_name or root)
		end

		if vim.bo.buftype ~= "" then
			return statusline.section_filename({ trunc_width = math.huge })
		end

		local name = vim.api.nvim_buf_get_name(0)
		if name == "" then
			return statusline.section_filename({ trunc_width = math.huge })
		end

		local path = vim.fn.fnamemodify(name, ":p")
		local root = git_root(path)
		local relative = root and vim.fs.relpath(root, path) or nil
		if relative == nil then
			relative = vim.fs.relpath(vim.fn.getcwd(), path)
		end
		if relative == nil or relative == "" then
			relative = vim.fn.fnamemodify(path, ":t")
		end

		return escape_statusline(relative) .. "%m%r"
	end

	statusline.setup({
		content = {
			active = function()
				local neovim_icon = ""
				local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
				local git = shorten_git(statusline.section_git({ trunc_width = 40 }))
				local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
				local filename = filename_section()
				local fileinfo = statusline.section_fileinfo({ trunc_width = math.huge })
				local location = "%l:%v"

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

	--		require("mini.notify").setup({ window = { winblend = 0 } })
	setup_statusline()

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

	require("noice").setup({
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
			},
		},
		-- you can enable a preset for easier configuration
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			command_palette = false, -- keep Noice's cmdline popup centered
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
	})
end

return M
