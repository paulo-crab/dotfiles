local gh = "https://github.com/"

local function PackAdd(package) 
	vim.pack.add({"https://github.com/" .. package})
end

PackAdd("nvim-mini/mini.icons")
PackAdd("stevearc/oil.nvim")

require('mini.icons').setup()

--- File Explorer
require("oil").setup({
          default_file_explorer = true,
	  columns = {
		  "icon",
	  },
	  delete_to_trash = true,
	  keymaps = {
	    ["<CR>"] = { "actions.select", opts = { vertical = true}}, 
          },
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

vim.api.nvim_create_autocmd("VimEnter", {
desc = "Open Oil split to the left on startup",
callback = function()
  -- Only open Oil if we are not editing a specialized filetype (like a git commit)
  if vim.bo.filetype == "gitcommit" then return end

  -- Defer execution until Neovim is fully drawn and loaded
    vim.schedule(function()
      -- 1. Create a vertical split
      vim.cmd("vsplit")
      
      -- 2. Move the split to the far left
      vim.cmd("wincmd H")
      
      -- 3. Open Oil safely
      require("oil").open()
      
      -- 4. Set the sidebar width
      vim.cmd("vertical resize 30")
	vim.cmd("wincmd l")

    end)
end,
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

