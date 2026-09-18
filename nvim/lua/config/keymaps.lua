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

vim.keymap.set("n", "<leader>fe", function() require("mini.files").open() end , { desc = "Open File Explorer" })

--- Diagnostics with mini.extra
---
--- ChatGPT suggested bindings - TODO Tweak
local extra = require("mini.extra")

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation", })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Diagnostic details", })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions", })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", })

-- Diagnostics
vim.keymap.set("n", "<leader>db", function() extra.pickers.diagnostic({ scope = "current" }) end, { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>dw", function() extra.pickers.diagnostic({ scope = "all" }) end, { desc = "Workspace diagnostics" })

-- LSP navigation
vim.keymap.set("n", "<leader>lr", function() extra.pickers.lsp({ scope = "references" }) end, { desc = "References" })
vim.keymap.set("n", "<leader>ls", function() extra.pickers.lsp({ scope = "document_symbol" }) end, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>lS", function() extra.pickers.lsp({ scope = "workspace_symbol" }) end, { desc = "Workspace symbols" })

-- Other useful lists
vim.keymap.set("n", "<leader>fb", function() MiniPick.builtin.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", function() MiniPick.builtin.help() end, { desc = "Help" })
