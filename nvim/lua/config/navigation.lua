-- FFF: Fast File Finder
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(event)
    if event.data.updated then
      require('fff.download').download_or_build_binary()
    end
  end,
})

-- the plugin will automatically lazy load
vim.g.fff = {
  lazy_sync = true, -- start syncing only when the picker is open
  debug = {
    enabled = true,
    show_scores = true,
  },
}

vim.keymap.set(
  'n',
  'ff',
  function() require('fff').find_files() end,
  { desc = 'FFFind files' }
)

-- mini.pick

require("mini.pick").setup({mappings = {
    move_down = "<M-j>",
    move_up = "<M-k>",
    choose = "<M-l>",
  }}
)

require("mini.files").setup()

require("mini.icons").mock_nvim_web_devicons()

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

require("nvim-tree").setup({
  renderer = {
    icons = {
      webdev_colors = false,
    },
  },
})

