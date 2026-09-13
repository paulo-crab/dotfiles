vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wrap = false

vim.opt.clipboard=unnamed

vim.opt.undodir= vim.fn.stdpath("state") .. "/nvim/undo//"
vim.opt.autocomplete = true

vim.opt.swapfile = false

require("themes")
require("plugins")
