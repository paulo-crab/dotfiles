vim.keymap.set("s", "n", "nzz") -- center screen on hits when navigating search results

vim.keymap.set("n", "<C-left>", "<C-W><left>", { desc = "Move cursor to windown on left"})
vim.keymap.set("n", "<C-right>", "<C-W><right>", { desc = "Move cursor to windown on right"})
vim.keymap.set("n", "<C-up>", "<C-W><up>", { desc = "Move cursor to windown above"})
vim.keymap.set("n", "<C-down>", "<C-W><down>", { desc = "Move cursor to windown under"})

vim.keymap.set("n", "<C-h>", "<C-W><left>", { desc = "Move cursor to windown on left"})
vim.keymap.set("n", "<C-l>", "<C-W><right>", { desc = "Move cursor to windown on right"})
vim.keymap.set("n", "<C-k>", "<C-W><up>", { desc = "Move cursor to windown above"})
vim.keymap.set("n", "<C-j>", "<C-W><down>", { desc = "Move cursor to windown under"})

vim.keymap.set("i", "jk", "<Esc>")


--- Diagnostics with mini.extra
---
--- ChatGPT suggested bindings - TODO Tweak
local extra = require("mini.extra")


-- Diagnostics (prefix: [D]iagnostics)
vim.keymap.set("n", "<leader>db", function() extra.pickers.diagnostic({ scope = "current" }) end, { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>dw", function() extra.pickers.diagnostic({ scope = "all" }) end, { desc = "Workspace diagnostics" })

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation", })
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Diagnostic details", })

-- LSP navigation (prefix: [C]ode)
vim.keymap.set("n", "<leader>cfr", function() extra.pickers.lsp({ scope = "references" }) end, { desc = "References" })
vim.keymap.set("n", "<leader>cds", function() extra.pickers.lsp({ scope = "document_symbol" }) end, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>cws", function() extra.pickers.lsp({ scope = "workspace_symbol" }) end, { desc = "Workspace symbols" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions", })

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", })

-- Other useful lists (Buffers = [B]uffers)
local MiniPick = require("mini.pick")
vim.keymap.set("n", "<leader>bs", function() MiniPick.builtin.buffers() end, { desc = "Switch between buffers" })
vim.keymap.set("n", "<leader>bh", function() MiniPick.builtin.help() end, { desc = "Help" })

-- Navigation ([F]iles)
vim.keymap.set("n", "<leader>fe", function()
  require("nvim-tree.api").tree.open({
    path = vim.fn.getcwd(),
  })
end, { desc = "Open file tree at current directory" })

vim.keymap.set("n", "<leader>fc", function()
	MiniPick.builtin.files({
   		 cwd = vim.fn.stdpath("config"),
  	})
end
, { desc = "[c]onfiguration files"})

local MiniFiles = require("mini.files")

local minifiles_toggle = function(...)
    if MiniFiles.close() == nil then MiniFiles.open(...) end
  end

vim.keymap.set("n", "<leader>fp", function() minifiles_toggle() end , { desc = "Open Picker" })
