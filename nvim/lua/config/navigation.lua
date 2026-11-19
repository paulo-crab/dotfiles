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

local function toggle_preview_view()
	local right = vim.api.nvim_replace_termcodes("<Right>", true, true, true)
	vim.api.nvim_feedkeys(right, "n", false)
end

local function is_preview_view()
	local state = MiniPick.get_picker_state()
	if state == nil or state.buffers.preview == nil then
		return false
	end
	return vim.api.nvim_win_get_buf(state.windows.main) == state.buffers.preview
end

MiniPick.setup({
	window = {
		config = function()
			local height = math.floor(0.618 * vim.o.lines)
			local width = math.floor(0.618 * vim.o.columns)

			return {
				anchor = "NW",
				height = height,
				width = width,
				row = math.floor(0.5 * (vim.o.lines - height)),
				col = math.floor(0.5 * (vim.o.columns - width)),
			}
		end,
	},
	mappings = {
		caret_right = "",
		move_down = "<M-j>",
		move_up = "<M-k>",
		toggle_preview = "<Right>",
		-- MiniPick has one built-in key for this action; make Tab feed the same key.
		toggle_preview_tab = {
			char = "<Tab>",
			func = toggle_preview_view,
		},
		show_preview = {
			char = "<M-l>",
			func = function()
				if not is_preview_view() then
					toggle_preview_view()
				end
			end,
		},
		show_results = {
			char = "<M-h>",
			func = function()
				if is_preview_view() then
					toggle_preview_view()
				end
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
