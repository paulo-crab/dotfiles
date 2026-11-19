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

vim.diagnostic.config({ virtual_text = true })
