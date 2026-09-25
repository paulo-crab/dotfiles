-- FFF: Fast File Finder
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		if event.data.updated then
			require("fff.download").download_or_build_binary()
		end
	end,
})

-- the plugin will automatically lazy load
vim.g.fff = {
	lazy_sync = true, -- start syncing only when the picker is open
	git = {
		status_text_color = true,
	},
	debug = {
		enabled = false,
		show_scores = false,
	},
}

require("nvim-tree").setup({
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		severity = {
			min = vim.diagnostic.severity.ERROR,
			max = vim.diagnostic.severity.ERROR,
		},
	},
	renderer = {
		highlight_diagnostics = true,
		icons = {
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
				git = true,
			},
		},
	},
})

-- mini.pick

local MiniPick = require("mini.pick")

MiniPick.setup({
	mappings = {
		move_down = "<M-j>",
		move_up = "<M-k>",
		-- Built-in mapping fields hold a single key, so `choose` keeps its default
		-- `<CR>` and `<M-l>` is added as a custom action doing the same thing.
		choose_alt = {
			char = "<M-l>",
			func = function()
				local item = MiniPick.get_picker_matches().current
				if item == nil then
					return true
				end
				local ok, res = pcall(MiniPick.get_picker_opts().source.choose, item)
				-- Stop the picker unless `choose` asked to keep it open.
				return not (ok and res)
			end,
		},
	},
})

require("mini.files").setup()

-- Default Options
--
-- MiniFiles.config = {
--   -- Customization of shown content
--   content = {
--     -- Predicate for which file system entries to show
--     filter = nil,
--     -- Highlight group to use for a file system entry
--     highlight = nil,
--     -- Prefix text and highlight to show to the left of file system entry
--     prefix = nil,
--     -- Order in which to show file system entries
--     sort = nil,
--   },
--
--   -- Module mappings created only inside explorer.
--   -- Use `''` (empty string) to not create one.
--   mappings = {
--     close       = 'q',
--     go_in       = 'l',
--     go_in_plus  = 'L',
--     go_out      = 'h',
--     go_out_plus = 'H',
--     mark_goto   = "'",
--     mark_set    = 'm',
--     reset       = '<BS>',
--     reveal_cwd  = '@',
--     show_help   = 'g?',
--     synchronize = '=',
--     trim_left   = '<',
--     trim_right  = '>',
--   },
--
--   -- General options
--   options = {
--     -- Whether to delete permanently or move into module-specific trash
--     permanent_delete = true,
--     -- Whether to use for editing directories
--     use_as_default_explorer = true,
--     -- Timeout for synchronous LSP integration requests
--     lsp_timeout = 1000,
--   },
--
--   -- Customization of explorer windows
--   windows = {
--     -- Maximum number of windows to show side by side
--     max_number = math.huge,
--     -- Whether to show preview of file/directory under cursor
--     preview = false,
--     -- Width of focused window
--     width_focus = 50,
--     -- Width of non-focused window
--     width_nofocus = 15,
--     -- Width of preview window
--     width_preview = 25,
--   },
-- }
--
--
--
