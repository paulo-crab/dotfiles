local gh = "https://github.com/"

local function PackAdd(package) 
	vim.pack.add({"https://github.com/" .. package})
end

PackAdd("nvim-mini/mini.icons")
PackAdd("stevearc/oil.nvim")
PackAdd("sphamba/smear-cursor.nvim")
PackAdd("folke/which-key.nvim")

require('mini.icons').setup()
require('smear_cursor').setup({
smear_between_neighbor_lines = false,
})
require('which-key').setup({})

vim.keymap.set("n", "<leader>", function()
  require("which-key").show({ global = false })
end, { desc = "Show buffer keymaps" })


--- File Explorer
require("oil").setup({
          default_file_explorer = true,
	  columns = {
		  "icon",
	  },
	   keymaps = {
      ["<CR>"] = {
        callback = function()
          local oil = require("oil")
          local actions = require("oil.actions")
          local entry = oil.get_cursor_entry()

          if not entry then
            return
          end

          if entry.type == "directory" then
            -- Enter directory in the current Oil buffer
            actions.select.callback()
          else
            -- Open file in a new vertical split
            actions.select.callback({
              vertical = true,
            })
          end
        end,
        mode = "n",
     },	
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

vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory" }) 
