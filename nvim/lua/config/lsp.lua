require("mason").setup()

-- Keep Lua's server separate. EasyDotnet owns the C# Roslyn client so its
-- create-type-from-usage extension can provide the corresponding code action.
vim.lsp.enable({ "lua_ls" })

require("easy-dotnet").setup({
	picker = "basic",
	csproj_mappings = false,
	fsproj_mappings = false,
	enable_filetypes = false,
	auto_bootstrap_namespace = { enabled = false },
	projx_lsp = { enabled = false },
	lsp = {
		enabled = true,
		preload_roslyn = false,
		roslynator_enabled = false,
		easy_dotnet_analyzer_enabled = false,
		easy_dotnet_extension_enabled = true,
		create_type_from_usage = true,
		enhanced_rename = false,
		suggest_updates = false,
		razor = { enabled = false },
	},
	debugger = { auto_register_dap = false },
	test_runner = {
		auto_start_testrunner = false,
		mappings = {
			run_all_tests_from_buffer = { lhs = "<leader>tt" },
		},
	},
})

-- EasyDotnet remembers one selected solution per Neovim cwd. When cwd is the
-- monorepo root, that makes the first selected service solution apply to every
-- C# buffer in the repo. Resolve Roslyn's root from the current file instead,
-- so each service attaches to its own nearest solution.
local function has_dotnet_file(directory, pattern)
	local ok, entries = pcall(vim.fn.readdir, directory)
	if not ok then
		return false
	end

	for _, name in ipairs(entries) do
		if name:match(pattern) then
			return true
		end
	end

	return false
end

local function find_dotnet_directory(start_dir, pattern, stop_dir)
	local directory = start_dir
	while directory do
		if has_dotnet_file(directory, pattern) then
			return directory
		end
		if directory == stop_dir then
			break
		end

		local parent = vim.fs.dirname(directory)
		if parent == directory then
			break
		end
		directory = parent
	end
end

vim.lsp.config("easy_dotnet", {
	root_dir = function(bufnr, on_dir)
		local filepath = vim.api.nvim_buf_get_name(bufnr)
		if filepath == "" or filepath:match("^%a+://") then
			return
		end

		local file_dir = vim.fs.dirname(vim.fs.normalize(filepath))
		local repo_root = vim.fs.root(file_dir, ".git") or vim.fn.getcwd()
		local project_dir = find_dotnet_directory(file_dir, "%.csproj$", repo_root)
		local solution_dir = find_dotnet_directory(project_dir or file_dir, "%.slnx?$", repo_root)

		on_dir(solution_dir or project_dir or file_dir)
	end,
})

vim.diagnostic.config({ virtual_text = true })
