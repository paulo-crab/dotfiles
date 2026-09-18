vim.g.have_nerd_font = false
vim.g.mapleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
-- opt.statusline - TODO
opt.statuscolumn = "%@SignCb@%s%=%T%@NumCb@%l│%T"
opt.scrolloff = 10
opt.wrap = false

opt.swapfile=false

-- noselect: don't auto-select/auto-insert the first completion match while typing,
-- menuone: still show the menu even for a single match
opt.completeopt = { "menu", "menuone", "popup", "noselect" }

vim.schedule(function() opt.clipboard = 'unnamedplus' end) -- Schedule makes startup time faster since clipboard is synced after

