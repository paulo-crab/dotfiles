local map = vim.keymap.set

-- `fff.setup()` only assigns `vim.g.fff` and returns nothing, so the options
-- live in `config.navigation` and this is just the module handle.
local fff = require("fff")

local MiniPick = require("mini.pick")
local MiniFiles = require("mini.files")
local MiniExtra = require("mini.extra")
local NvimTree = require("nvim-tree.api")

-- General
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "n", "nzz", { desc = "Next search result centered" })
map("n", "N", "Nzz", { desc = "Previous search result centered" })

-- Copy a file location reference for sharing in Claude, Codex, etc.
local function relative_file_path()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		vim.notify("Current buffer has no file path", vim.log.levels.WARN)
		return nil
	end

	local path = vim.fn.fnamemodify(name, ":p")
	local root = vim.fs.root(vim.fs.dirname(path), ".git") or vim.fn.getcwd()
	return vim.fs.relpath(root, path) or path
end

local function yank_file_reference(first_line, last_line)
	local path = relative_file_path()
	if not path then
		return
	end

	local reference = path .. ":" .. first_line
	if last_line and last_line ~= first_line then
		reference = reference .. "-" .. last_line
	end

	vim.fn.setreg("+", reference)
	vim.notify("Copied: " .. reference, vim.log.levels.INFO)
end

map("n", "<leader>yf", function()
	local line = vim.fn.line(".")
	yank_file_reference(line, line)
end, { desc = "Copy file:line reference" })

map("x", "<leader>yf", function()
	local first_line = vim.fn.line("v")
	local last_line = vim.fn.line(".")
	if first_line > last_line then
		first_line, last_line = last_line, first_line
	end
	yank_file_reference(first_line, last_line)
	local escape = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys(escape, "n", true)
end, { desc = "Copy file:line range reference" })

local function git_result(root, args)
	local command = { "git", "-C", root }
	vim.list_extend(command, args)
	return vim.system(command, { text = true }):wait()
end

local function github_web_url(remote)
	remote = vim.trim(remote):gsub("%.git$", ""):gsub("/$", "")
	local host, repository = remote:match("^git@([^:]+):(.+)$")
	if not host then
		host, repository = remote:match("^ssh://git@([^/]+)/(.+)$")
	end
	if not host then
		host, repository = remote:match("^https?://([^/]+)/(.+)$")
	end
	if not host or not repository then
		return nil
	end

	return "https://" .. host:gsub("^.-@", "") .. "/" .. repository:gsub("^/", "")
end

local function github_path(path)
	return path:gsub("([^%w%-%._~/])", function(char)
		return string.format("%%%02X", char:byte())
	end)
end

local function copy_github_permalink(first_line, last_line, visual_mode)
	local function finish()
		if visual_mode then
			local escape = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
			vim.api.nvim_feedkeys(escape, "n", true)
		end
	end
	local function fail(message, level)
		vim.notify(message, level)
		finish()
	end

	local filename = vim.api.nvim_buf_get_name(0)
	if filename == "" then
		fail("Current buffer has no file path", vim.log.levels.WARN)
		return
	end

	local directory = vim.fn.fnamemodify(filename, ":p:h")
	local root_result = vim.system({ "git", "-C", directory, "rev-parse", "--show-toplevel" }, { text = true }):wait()
	if root_result.code ~= 0 then
		fail("Current file is not inside a Git repository", vim.log.levels.WARN)
		return
	end

	local root = vim.trim(root_result.stdout)
	local relative_path = vim.fs.relpath(root, vim.fn.fnamemodify(filename, ":p"))
	local remote_result = git_result(root, { "remote", "get-url", "origin" })
	local commit_result = git_result(root, { "rev-parse", "HEAD" })
	if not relative_path or remote_result.code ~= 0 or commit_result.code ~= 0 then
		fail("Could not determine the GitHub repository or commit", vim.log.levels.ERROR)
		return
	end

	if vim.bo.modified then
		fail("Save the file before copying a GitHub permalink", vim.log.levels.WARN)
		return
	end

	local committed_file = git_result(root, { "cat-file", "-e", "HEAD:" .. relative_path })
	local file_diff = git_result(root, { "diff", "--quiet", "HEAD", "--", relative_path })
	if committed_file.code ~= 0 or file_diff.code == 1 then
		fail("Commit this file before copying a GitHub permalink", vim.log.levels.WARN)
		return
	elseif file_diff.code ~= 0 then
		fail("Could not check whether the file matches the current commit", vim.log.levels.ERROR)
		return
	end

	local repository_url = github_web_url(remote_result.stdout)
	if not repository_url then
		fail("The origin remote is not a supported GitHub URL", vim.log.levels.ERROR)
		return
	end

	local line_range = "#L" .. first_line
	if last_line ~= first_line then
		line_range = line_range .. "-L" .. last_line
	end

	local permalink = repository_url
		.. "/blob/"
		.. vim.trim(commit_result.stdout)
		.. "/"
		.. github_path(relative_path)
		.. line_range
	vim.fn.setreg("+", permalink)
	vim.notify("Copied GitHub permalink: " .. relative_path .. line_range, vim.log.levels.INFO)
	finish()
end

map("n", "<leader>yg", function()
	local line = vim.fn.line(".")
	copy_github_permalink(line, line, false)
end, { desc = "Copy GitHub permalink for current line" })

map("x", "<leader>yg", function()
	local first_line = vim.fn.line("v")
	local last_line = vim.fn.line(".")
	if first_line > last_line then
		first_line, last_line = last_line, first_line
	end
	copy_github_permalink(first_line, last_line, true)
end, { desc = "Copy GitHub permalink for selected lines" })

-- Buffer navigation
map("n", "<leader>bb", function()
	local delete_selected_buffer = function()
		local item = MiniPick.get_picker_matches().current
		if item == nil or item.bufnr == nil then
			return
		end

		local ok, deleted = pcall(require("mini.bufremove").delete, item.bufnr)
		if not ok then
			vim.notify(tostring(deleted), vim.log.levels.ERROR)
			return
		end
		if not deleted then
			return
		end

		local items = MiniPick.get_picker_items()
		MiniPick.set_picker_items(vim.tbl_filter(function(buffer)
			return buffer.bufnr ~= item.bufnr
		end, items))
	end

	MiniPick.builtin.buffers(nil, {
		mappings = {
			delete_buffer = { char = "<C-d>", func = delete_selected_buffer },
		},
	})
end, { desc = "Switch buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- LSP navigation
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })

-- Diagnostics
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
map("n", "<leader>db", function()
	MiniExtra.pickers.diagnostic({ scope = "current" })
end, { desc = "Buffer diagnostics" })
map("n", "<leader>dw", function()
	MiniExtra.pickers.diagnostic({ scope = "all" })
end, { desc = "Workspace diagnostics" })
map("n", "<leader>dr", "<cmd>Dotnet diagnostic errors<cr>", { desc = "Recheck workspace errors" })
map("n", "<leader>dR", "<cmd>Dotnet diagnostic warnings<cr>", { desc = "Recheck workspace errors and warnings" })
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Diagnostic details" })

-- Use Neovim's native K and gr* LSP mappings for code actions and navigation.
-- Use MiniExtra pickers where a navigable result list is more useful.
map("n", "grr", function()
	MiniExtra.pickers.lsp({ scope = "references" })
end, { desc = "Find references" })

-- `grw` keeps workspace symbols within the LSP mapping family.
map("n", "grw", function()
	MiniExtra.pickers.lsp({ scope = "workspace_symbol_live" })
end, { desc = "Workspace symbols" })

-- Git
-- Some sensible stuff stolen from MiniMax configuration (https://nvim-mini.org/MiniMax/configs/)
-- g is for 'Git'. Common usage:
-- - `<Leader>gs` - show information at cursor
-- - `<Leader>go` - toggle 'mini.diff' overlay to show in-buffer unstaged changes
-- - `<Leader>gd` - show unstaged changes as a patch in separate tabpage
-- - `<Leader>gL` - show Git log of current file
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. " --follow -- %"

map("n", "<leader>ga", "<cmd>Git diff --cached<cr>", { desc = "Added diff" })
map("n", "<leader>gA", "<cmd>Git diff --cached -- %<cr>", { desc = "Added diff buffer" })
map("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Commit" })
map("n", "<leader>gC", "<cmd>Git commit --amend<cr>", { desc = "Commit amend" })
map("n", "<leader>gd", "<cmd>Git diff<cr>", { desc = "Diff" })
map("n", "<leader>gD", "<cmd>Git diff -- %<cr>", { desc = "Diff buffer" })
map("n", "<leader>gl", "<cmd>" .. git_log_cmd .. "<cr>", { desc = "Log" })
map("n", "<leader>gL", "<cmd>" .. git_log_buf_cmd .. "<cr>", { desc = "Log buffer" })
map("n", "<leader>gv", "<cmd>DiffBanditGit<cr>", { desc = "Review Git changes" })
map("n", "<leader>gV", "<cmd>DiffBanditGitCurrent<cr>", { desc = "Review current file" })
map("n", "<leader>gp", "<cmd>DiffBanditCommitPanel<cr>", { desc = "Git commit panel" })
map("n", "<leader>gm", "<cmd>DiffBanditGitMenu<cr>", { desc = "Git review menu" })
map("n", "<leader>go", "<cmd>lua MiniDiff.toggle_overlay()<cr>", { desc = "Toggle overlay" })
map("n", "<leader>gs", "<cmd>lua MiniGit.show_at_cursor()<cr>", { desc = "Show at cursor" })
map("x", "<leader>gs", "<cmd>lua MiniGit.show_at_cursor()<cr>", { desc = "Show at selection" })
map("n", "<leader>gb", function()
	local file = vim.fn.expand("%")
	local blame_line = vim.fn.line(".")

	vim.system({
		"git",
		"blame",
		"-L",
		blame_line .. "," .. blame_line,
		"--porcelain",
		file,
	}, { text = true }, function(result)
		vim.schedule(function()
			local author = result.stdout:match("\nauthor ([^\n]+)")
			local summary = result.stdout:match("\nsummary ([^\n]+)")
			local time = result.stdout:match("\nauthor%-time (%d+)")

			if not author then
				return
			end

			local date = time and os.date("%Y-%m-%d", tonumber(time)) or ""

			local lines = {
				"󰊢 " .. author .. " • " .. date,
				summary or "",
			}

			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			local ns = vim.api.nvim_create_namespace("git_blame_float")

			vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
				end_col = #lines[1],
				hl_group = "Special",
			})

			vim.api.nvim_buf_set_extmark(buf, ns, 1, 0, {
				end_col = #lines[2],
				hl_group = "Comment",
			})
			local width = math.max(vim.fn.strdisplaywidth(lines[1]), vim.fn.strdisplaywidth(lines[2]))

			local win = vim.api.nvim_open_win(buf, false, {
				relative = "cursor",
				row = 1,
				col = 1,
				width = width + 2,
				height = 2,
				style = "minimal",
				border = "rounded",
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
				callback = function(args)
					if not vim.api.nvim_win_is_valid(win) then
						return true
					end

					if args.event ~= "CursorMoved" or vim.fn.line(".") ~= blame_line then
						vim.api.nvim_win_close(win, true)
						return true
					end
				end,
			})
		end)
	end)
end, { desc = "[B]lame line" }) -- Files / Find

local function nvimtree_toggle()
	NvimTree.tree.toggle({ path = vim.fn.getcwd(), focus = true })
	if NvimTree.tree.is_visible() then
		vim.cmd("vertical resize 30")
	end
end
map("n", "<leader>fe", nvimtree_toggle, { desc = "Toggle file explorer" })
map("n", "<leader>fr", function()
	NvimTree.tree.find_file({ open = true, focus = true, update_root = true })
end, { desc = "Reveal current file in tree" })
map("n", "<leader>fm", function()
	MiniFiles.open()
end, { desc = "Toggle mini.files" })
map("n", "<leader><leader>", function()
	fff.find_files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
	fff.live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fz", function()
	fff.live_grep({ grep = { modes = { "fuzzy", "plain" } } })
end, { desc = "Fuzzy grep" })
map({ "n", "x" }, "<leader>fw", function()
	fff.live_grep_under_cursor()
end, { desc = "Grep word / selection" })
-- fff indexes files only and its `find_files` takes no filter callback, so
-- directories come from `fd` through mini.pick instead.
map("n", "<leader>fd", function()
	MiniPick.builtin.cli(
		{ command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" } },
		{
			source = {
				name = "Directories",
				choose = function(item)
					MiniFiles.open(item)
				end,
			},
		}
	)
end, { desc = "Find directories" })

-- Help
map("n", "<leader>h", function()
	MiniPick.builtin.help()
end, { desc = "Help" })

-- Which-key
local ok, wk = pcall(require, "which-key")

if ok then
	wk.setup({
		delay = 300,
		triggers = {
			{ "<auto>", mode = "nixsotc" },
			{ "gr", mode = { "n", "v" } },
		},
	})

	-- Which-key trims ordinary trailing spaces from its icon column, so use a
	-- non-breaking space to keep a clear gap before these LSP descriptions.
	local icon_gap = string.char(194, 160)
	-- Use fuller Material Design glyphs so the icons read clearly at terminal size.
	local code_icon = { icon = "󰅴" .. icon_gap, color = "orange" }
	local search_icon = { icon = "󰍉" .. icon_gap, color = "green" }

	wk.add({
		{ "<leader>b", group = "[B]uffers" },
		{ "<leader>d", group = "[D]iagnostics" },
		{ "<leader>f", group = "[F]iles / Find" },
		{ "<leader>g", group = "[G]it" },
		{ "<leader>t", group = "[T]oggles / tests" },
		{ "<leader>tz", desc = "Toggle focus mode" },
		{ "<leader>y", group = "[Y]ank / Share" },
		{ "<leader>yf", desc = "Copy file:line reference", mode = { "n" } },
		{ "<leader>yf", desc = "Copy file:line range reference", mode = { "x" } },
		{ "<leader>yg", desc = "Copy GitHub permalink for current line", mode = { "n" } },
		{ "<leader>yg", desc = "Copy GitHub permalink for selected lines", mode = { "x" } },
		{ "gO", desc = "Document symbols (current file)" },
		{ "gr", group = "[L]SP" },
		-- These are Which-key labels only; Neovim's built-in LSP mappings stay intact.
		{ "gra", desc = "Code action", icon = code_icon, mode = { "n", "v" } },
		{ "grc", desc = "Create type from usage", icon = code_icon },
		{ "gri", desc = "Go to implementation" },
		{ "grn", desc = "Rename symbol" },
		{ "grr", desc = "Find references", icon = search_icon },
		{ "grt", desc = "Go to type definition" },
		{ "grx", desc = "Run CodeLens action", icon = code_icon },
	}, { create = false })
end

-- Use mini.basics for sensible mappings
require("mini.basics").setup({
	mappings = {
		basic = true,
		option_toggle_prefix = "<leader>t",
		windows = true,
		move_with_alt = true,
	},
})

map("n", "<leader>tz", function()
	require("config.focus").toggle()
end, { desc = "Toggle focus mode" })

-- mini.basics replaces these Neovim 0.12 LSP mappings with its own defaults.
-- Use a MiniPick for document symbols and restore Insert-mode signature help.
map("n", "gO", function()
	MiniExtra.pickers.lsp({ scope = "document_symbol" })
end, { desc = "Document symbols (current file)" })
map("i", "<C-S>", vim.lsp.buf.signature_help, { desc = "LSP: Signature help" })

-- Run EasyDotnet's create-type action directly; `gra` remains the general picker.
map("n", "grc", function()
	vim.lsp.buf.code_action({
		apply = true,
		filter = function(action)
			local command = action.command
			if type(command) == "table" then
				command = command.command
			end
			return command == "easy-dotnet.roslyn.createTypeFromUsage"
		end,
	})
end, { desc = "Create type from usage" })
