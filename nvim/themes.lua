
-- Catppucccinnnn
local gh = "https://github.com/"

vim.pack.add({ gh .. "catppuccin/nvim" })	
vim.pack.add({ gh .. "morhetz/gruvbox"  })

if vim.o.background == "dark" then
  vim.cmd("colorscheme catppuccin-mocha")
else
  vim.cmd("colorscheme gruvbox")
end

vim.api.nvim_create_autocmd( "OptionSet", { 
	pattern = "background",
	callback = function ()
  if vim.o.background == "dark" then
    vim.cmd("colorscheme catppuccin-mocha")
  else
    vim.cmd("colorscheme gruvbox")
  end
end,
})

