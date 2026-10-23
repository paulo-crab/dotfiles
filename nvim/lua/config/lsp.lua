--=========================================
--==              MASON                  ==--
--==       LSP PACKAGE MANAGER           ==--
--==                                     ==--
--== installs:                           ==--
--==    - C#:  roslyn, csharpier         ==--
--==    - lua: lua_ls                    ==--
--=========================================--

require("mason").setup()

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

-- nvim_tree.events.subscribe(nvim_tree.events.event.treeopen, function()
-- 	local root_node = nvim_tree.tree.get_nodes()
-- 	local tree_root = root_node and root_node.absolute_path
-- 	local project_root = tree_root and roslyn_root(tree_root)
-- 	if not project_root then
-- 		return
-- 	end
--
-- 	vim.defer_fn(function()
-- 		local current_root = nvim_tree.tree.get_nodes()
-- 		if not current_root or current_root.absolute_path ~= tree_root then
-- 			return
-- 		end
--
-- 		local config = vim.deepcopy(vim.lsp.config.roslyn)
-- 		config.root_dir = project_root
-- 		vim.lsp.start(config, { attach = false })
-- 	end, roslyn_start_delay_ms)
-- end)
--
vim.diagnostic.config({ virtual_text = true })

--	local dotnet = require("easy-dotnet")

-- dotnet.setup({
-- 	managed_terminal = {
-- 		auto_hide = true, -- auto hides terminal if exit code is 0
-- 		auto_hide_delay = 1000, -- delay before auto hiding, 0 = instant
-- 		mappings = {
-- 			next_tab = { lhs = "<Tab>", desc = "Next terminal tab" },
-- 			prev_tab = { lhs = "<S-Tab>", desc = "Previous terminal tab" },
-- 			new_terminal = { lhs = "+", desc = "New user terminal" },
-- 			close_terminal = { lhs = "X", desc = "Close current terminal tab" },
-- 			hide_panel = { lhs = "q", desc = "Hide terminal panel" },
-- 		},
-- 	},
-- 	-- Optional configuration for external terminals (matches nvim-dap structure)
-- 	external_terminal = nil,
-- 	projx_lsp = {
-- 		enabled = true,
-- 	},
-- 	lsp = {
-- 		enabled = true, -- Enable builtin roslyn lsp
-- 		set_fold_expr = false,
-- 		preload_roslyn = true, -- Start loading roslyn before any buffer is opened
-- 		roslynator_enabled = true, -- Automatically enable roslynator analyzer
-- 		easy_dotnet_analyzer_enabled = true, -- Enable roslyn analyzer from easy-dotnet-server
-- 		easy_dotnet_extension_enabled = false, -- Needs to be true for enhanced_rename and create_type_from_usage
-- 		enhanced_rename = false, -- auto rename file when renaming class
-- 		create_type_from_usage = false, -- code action for creating class from unresolved symbol in a separate file
-- 		restart_roslyn_on_branch_change = false, -- Restart Roslyn when Git HEAD changes
-- 		auto_refresh_codelens = true,
-- 		suggest_updates = true, -- Periodically suggest roslyn-language-server updates
-- 		analyzer_assemblies = {}, -- Any additional roslyn analyzers you might use like SonarAnalyzer.CSharp
-- 		razor = {
-- 			enabled = true,
-- 			html = {
-- 				enabled = true,
-- 				cmd = nil, -- Auto-detect project node_modules/.bin/vscode-html-language-server, then PATH
-- 				request_timeout = 5000,
-- 			},
-- 		},
-- 		config = {},
-- 	},
-- 	debugger = {
-- 		-- Path to custom coreclr DAP adapter
-- 		-- When set, this fully overrides `engine`; easy-dotnet-server uses this binary as-is.
-- 		-- When nil, easy-dotnet-server falls back to its own bundled debugger selected by `engine`.
-- 		bin_path = nil,
-- 		-- Which bundled debugger to use when `bin_path` is nil.
-- 		--   "netcoredbg" (default) — Samsung netcoredbg
-- 		--   "dncdbg"               — viewizard/dncdbg (a fork of netcoredbg with a richer set of features)
-- 		--   "sharpdbg"             — MattParkerDev/sharpdbg (a new debugger written in C#)
-- 		engine = "netcoredbg",
-- 		console = "integratedTerminal", -- Controls where the target app runs: "integratedTerminal" (Neovim buffer) or "externalTerminal" (OS window)
-- 		apply_value_converters = true,
-- 		auto_register_dap = true,
-- 		-- Sample the debugged process' CPU/memory usage so the `easy-dotnet_cpu` and `easy-dotnet_mem`
-- 		-- dapui widgets have data to draw. Set to false to turn sampling off and unregister the widgets.
-- 		mem_cpu_usage = true,
-- 		mappings = {
-- 			open_variable_viewer = { lhs = "T", desc = "open variable viewer" },
-- 		},
-- 	},
-- 	---@type TestRunnerOptions
-- 	test_runner = {
-- 		auto_start_testrunner = true,
-- 		hide_legend = false,
-- 		-- Set to true when using neotest to avoid duplicate signs and conflicting buffer keymaps.
-- 		neotest_integration = false,
-- 		---@type "split" | "vsplit" | "float" | "buf"
-- 		viewmode = "float",
-- 		---@type number|nil
-- 		vsplit_width = nil,
-- 		---@type string|nil "topleft" | "topright"
-- 		vsplit_pos = nil,
-- 		icons = {
-- 			passed = "",
-- 			skipped = "",
-- 			failed = "",
-- 			success = "",
-- 			reload = "",
-- 			test = "",
-- 			sln = "󰘐",
-- 			project = "󰘐",
-- 			dir = "",
-- 			package = "",
-- 			class = "",
-- 			build_failed = "󰒡",
-- 		},
-- 		mappings = {
-- 			run_test_from_buffer = { lhs = "<leader>r", desc = "run test from buffer" },
-- 			run_all_tests_from_buffer = { lhs = "<leader>t", desc = "Run all tests in file" },
-- 			get_build_errors = { lhs = "<leader>e", desc = "get build errors" },
-- 			peek_stack_trace_from_buffer = { lhs = "<leader>p", desc = "peek stack trace from buffer" },
-- 			debug_test_from_buffer = { lhs = "<leader>d", desc = "run test from buffer" },
-- 			debug_test = { lhs = "<leader>d", desc = "debug test" },
-- 			go_to_file = { lhs = "<leader>g", desc = "go to file" },
-- 			run_all = { lhs = "<leader>R", desc = "run all tests" },
-- 			run = { lhs = "<leader>r", desc = "run test" },
-- 			peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
-- 			expand = { lhs = "o", desc = "expand" },
-- 			expand_node = { lhs = "E", desc = "expand node" },
-- 			collapse_all = { lhs = "W", desc = "collapse all" },
-- 			close = { lhs = "q", desc = "close testrunner" },
-- 			refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
-- 			cancel = { lhs = "<C-c>", desc = "cancel in-flight operation" },
-- 			next_failure = { lhs = "]f", desc = "jump to next failing test" },
-- 			prev_failure = { lhs = "[f", desc = "jump to previous failing test" },
-- 		},
-- 	},
-- 	new = {
-- 		project = {
-- 			prefix = "sln", -- "sln" | "none"
-- 		},
-- 	},
-- 	csproj_mappings = true,
-- 	fsproj_mappings = true,
-- 	auto_bootstrap_namespace = {
-- 		--block_scoped, file_scoped
-- 		type = "block_scoped",
-- 		enabled = true,
-- 		use_clipboard_json = {
-- 			behavior = "prompt", --'auto' | 'prompt' | 'never',
-- 			register = "+", -- which register to check
-- 		},
-- 	},
-- 	server = {
-- 		use_visual_studio = false, -- Set true for .NET Framework support on Windows
-- 		---@type nil | "Off" | "Critical" | "Error" | "Warning" | "Information" | "Verbose" | "All"
-- 		log_level = nil,
-- 	},
-- 	-- choose which picker to use with the plugin
-- 	-- possible values are "telescope" | "fzf" | "snacks" | "basic"
-- 	-- if no picker is specified, the plugin will determine
-- 	-- the available one automatically with this priority:
-- 	--  snacks -> fzf -> telescope ->  basic
-- 	notifications = {
-- 		--Set this to false if you have configured lualine to avoid double logging
-- 		handler = function(start_event)
-- 			local spinner = require("easy-dotnet.ui-modules.spinner").new()
-- 			spinner:start_spinner(function()
-- 				return start_event.job.name
-- 			end)
-- 			---@param finished_event JobEvent
-- 			return function(finished_event)
-- 				spinner:stop_spinner(finished_event.result.msg, finished_event.result.level)
-- 			end
-- 		end,
-- 	},
-- 	diagnostics = {
-- 		default_severity = "error",
-- 		setqflist = false,
-- 	},
-- 	outdated = {
-- 		mappings = {
-- 			upgrade = { lhs = "<leader>pu", desc = "upgrade package under cursor" },
-- 			upgrade_all = { lhs = "<leader>pa", desc = "upgrade all outdated packages" },
-- 		},
-- 	},
-- })
