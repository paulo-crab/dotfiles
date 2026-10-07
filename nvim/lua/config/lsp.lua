--=========================================--
--==              MASON                  ==--
--==       LSP PACKAGE MANAGER           ==--
--==                                     ==--
--== installs:                           ==--
--==    - C#:  roslyn, csharpier         ==--
--==    - lua: lua_ls                    ==--
--=========================================--

require("mason").setup()

-- Runs whenever an LSP attaches to a buffer.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("paulocrab-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration") -- WARN: declaration, not definition
	end,
})

-- Each server's full config (cmd, filetypes, root_markers, settings, ...) lives in
-- its own file under lsp/<name>.lua (auto-loaded from runtimepath). This just enables them.
vim.lsp.enable({ "roslyn", "lua_ls" })

-- Opening a C# project in nvim-tree has no C# buffer to trigger LSP activation.
-- Prestart Roslyn for project roots after the tree has settled; attach it only
-- when a real C# buffer is opened.
local nvim_tree = require("nvim-tree.api")
local roslyn_start_delay_ms = 1200

local function roslyn_root(path)
	local solution_root = vim.fs.root(path, function(name)
		return name:match("%.sln[x]?$") ~= nil
	end)
	if solution_root then
		return solution_root
	end
	return vim.fs.root(path, function(name)
		return name:match("%.csproj$") ~= nil
	end)
end

nvim_tree.events.subscribe(nvim_tree.events.Event.TreeOpen, function()
	local root_node = nvim_tree.tree.get_nodes()
	local tree_root = root_node and root_node.absolute_path
	local project_root = tree_root and roslyn_root(tree_root)
	if not project_root then
		return
	end

	vim.defer_fn(function()
		local current_root = nvim_tree.tree.get_nodes()
		if not current_root or current_root.absolute_path ~= tree_root then
			return
		end

		local config = vim.deepcopy(vim.lsp.config.roslyn)
		config.root_dir = project_root
		vim.lsp.start(config, { attach = false })
	end, roslyn_start_delay_ms)
end)

vim.diagnostic.config({ virtual_text = true })
