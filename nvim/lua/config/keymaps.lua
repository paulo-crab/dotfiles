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

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Buffer navigation
map("n", "<leader>bb", function()
	MiniPick.builtin.buffers()
end, { desc = "Switch buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- LSP navigation
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
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
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Diagnostic details" })

-- Code / LSP
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>cR", function()
	MiniExtra.pickers.lsp({ scope = "references" })
end, { desc = "References" })
map("n", "<leader>cs", function()
	MiniExtra.pickers.lsp({ scope = "document_symbol" })
end, { desc = "Document symbols" })
map("n", "<leader>cS", function()
	MiniExtra.pickers.lsp({ scope = "workspace_symbol" })
end, { desc = "Workspace symbols" })
map("n", "<leader>ci", function()
	MiniExtra.pickers.lsp({ scope = "implementation" })
end, { desc = "Implementations" })

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
	wk.setup({ delay = 300 })

	wk.add({
		{ "<leader>b", group = "[B]uffers" },
		{ "<leader>c", group = "[C]ode" },
		{ "<leader>d", group = "[D]iagnostics" },
		{ "<leader>f", group = "[F]iles / Find" },
		{ "<leader>g", group = "[G]it" },
		{ "<leader>t", group = "[T]ests" },
		{ "<leader>T", group = "[T]oggle common options" },
	})
end

-- Use mini.basics for sensible mappings
require("mini.basics").setup({
	mappings = {
		basic = true,
		option_toggle_prefix = "<leader>T",
		windows = true,
		move_with_alt = true,
	},
})
