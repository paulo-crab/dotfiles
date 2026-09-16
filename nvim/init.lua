require('vim._core.ui2').enable({ enable = true })

vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wrap = false
-- use system clipboard as default
vim.opt.cb= "unnamed"

vim.opt.undodir= vim.fn.stdpath("state") .. "/nvim/undo//"
	
vim.opt.swapfile = false

-- Leader mapping	
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("themes")
require("plugins")
