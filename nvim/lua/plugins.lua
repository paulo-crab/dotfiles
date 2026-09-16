local gh = "https://github.com/"
local function PackAdd(package) 
	vim.pack.add({"https://github.com/" .. package})
end

PackAdd("nvim-mini/mini.icons")
PackAdd("stevearc/oil.nvim")
PackAdd("sphamba/smear-cursor.nvim")
PackAdd("folke/which-key.nvim")
PackAdd("dmtrKovalenko/fff.nvim")

require('mini.icons').setup()
require('smear_cursor').setup({
	smear_between_neighbor_lines = false,
})

local wk = require("which-key")

wk.setup({})

wk.add({
  { "<leader>f", group = "Find" },
})

vim.keymap.set("n", "<leader>?", "<cmd>WhichKey<cr>", {
  desc = "Show which-key",
})
--- File Explorer
require("oil").setup({
          default_file_explorer = true,
	  columns = {
		  "icon",
	  },
	  delete_to_trash = true,
	  skip_confirm_for_simple_edits = false,
	  window = {
	    max_width = 0,
	    max_height = 0,
	    border = "rounded",
	    win_options = {
	      wrap = false,
	    },
	  },
})

vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory" }) 


-- Fast File Finder: Fuzzy look up, Grep lookup, etc,etc ... 

vim.api.nvim_create_autocmd('PackChanged', {
      callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'fff' and (kind == 'install' or kind == 'update') then
          if not ev.data.active then vim.cmd.packadd('fff') end
          require('fff.download').download_or_build_binary()
        end
      end,
    })
    
vim.g.fff = {
      lazy_sync = true,
      debug = { enabled = true, show_scores = true },
}

vim.keymap.set('n', '<leader>ff', function() require('fff').find_files() end, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', function() 
	require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } })
	end, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fz', function() require('fff').find_files() end, { desc = 'Fuzzy grep' })
vim.keymap.set({'n', 'x'}, '<leader>fc', 
        function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
        { desc = 'Search current word/selection' })


-- vim.api.nvim_create_autocmd("VimEnter", {
-- desc = "Open Oil split to the left on startup",
-- callback = function()
--   -- Only open Oil if we are not editing a specialized filetype (like a git commit)
--   if vim.bo.filetype == "gitcommit" then return end
-- 
--   -- Defer execution until Neovim is fully drawn and loaded
--     vim.schedule(function()
--       -- 1. Create a vertical split
--       vim.cmd("vsplit")
--       
--       -- 2. Move the split to the far left
--       vim.cmd("wincmd H")
--       
--       -- 3. Open Oil safely
--       require("oil").open()
--       
--       -- 4. Set the sidebar width
--       vim.cmd("vertical resize 30")
-- 	vim.cmd("wincmd l")
-- 
--     end)
-- end,
-- })

