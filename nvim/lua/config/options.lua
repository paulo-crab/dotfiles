vim.g.have_nerd_font = false
vim.g.mapleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.statuscolumn = "%@SignCb@%s%=%T%@NumCb@%l│%T"
opt.scrolloff = 25
opt.wrap = false

-- No swap files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

opt.laststatus = 3

-- noselect: don't auto-select/auto-insert the first completion match while typing,
-- menuone: still show the menu even for a single match
opt.completeopt = { "menu", "menuone", "popup", "noselect" }

-- " update vim after file update from outside
vim.opt.autoread = true

-- " Indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.schedule(function()
	opt.clipboard = "unnamedplus"
end) -- Schedule makes startup time faster since clipboard is synced after

-- " Add the g flag to search/replace by default
vim.opt.gdefault = true

-- Save undo history
vim.o.undofile = true
vim.opt.undodir = os.getenv("XDG_STATE_HOME") .. "/.vim/undodir"

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300
