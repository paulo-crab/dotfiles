local map = vim.keymap.set

local fff = require("fff")
local MiniPick = require("mini.pick")
local MiniFiles = require("mini.files")
local MiniExtra = require("mini.extra")
local NvimTree = require("nvim-tree.api")

-- General
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "n", "nzz", { desc = "Next search result centered" })
map("n", "N", "Nzz", { desc = "Previous search result centered" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-left>", "<C-w>h", { desc = "Window left" })
map("n", "<C-down>", "<C-w>j", { desc = "Window down" })
map("n", "<C-up>", "<C-w>k", { desc = "Window up" })
map("n", "<C-right>", "<C-w>l", { desc = "Window right" })

-- LSP navigation
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })

-- Diagnostics
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
map("n", "<leader>db", function() MiniExtra.pickers.diagnostic({ scope = "current" }) end, { desc = "Buffer diagnostics" })
map("n", "<leader>dw", function() MiniExtra.pickers.diagnostic({ scope = "all" }) end, { desc = "Workspace diagnostics" })
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Diagnostic details" })

-- Code / LSP
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>cR", function() MiniExtra.pickers.lsp({ scope = "references" }) end, { desc = "References" })
map("n", "<leader>cs", function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end, { desc = "Document symbols" })
map("n", "<leader>cS", function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end, { desc = "Workspace symbols" })
map("n", "<leader>ci", function() MiniExtra.pickers.lsp({ scope = "implementation" }) end, { desc = "Implementations" })

-- Buffers
map("n", "<leader>bb", function() MiniPick.builtin.buffers() end, { desc = "Switch buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Files / Find

local function nvimtree_toggle()
  NvimTree.tree.toggle({ path = vim.fn.getcwd(), focus = true })
  if NvimTree.tree.is_visible() then
    vim.cmd("vertical resize 30")
  end
end
map("n", "<leader>fe", nvimtree_toggle, { desc = "Toggle file explorer" })
map("n", "<leader>fm", function() MiniFiles.open() end, { desc = "Toggle mini.files" })
map("n", "<leader>ff", function() fff.find_files() end, { desc = "Find files" })
map("n", "<leader>fg", function() fff.live_grep() end, { desc = "Live grep" })
map("n", "<leader>fz", function() fff.live_grep({ grep = { modes = { "fuzzy", "plain" } } }) end, { desc = "Fuzzy grep" })
map({ "n", "x" }, "<leader>fw", function() fff.live_grep_under_cursor() end, { desc = "Grep word / selection" })
vim.keymap.set("n", "<leader>fd", function()
  fff.find_files({
    prompt = "Directories: ",
    transform = function(item)
      -- Keep only entries whose path is a directory
      return vim.fn.isdirectory(item.path) == 1
    end,
  })
end, { desc = "Find directories" })

-- Help
map("n", "<leader>h", function() MiniPick.builtin.help() end, { desc = "Help" })

-- Which-key
local ok, wk = pcall(require, "which-key")

if ok then
  wk.setup({ delay = 300 })

  wk.add({
    { "<leader>b", group = "Buffers" },
    { "<leader>c", group = "Code" },
    { "<leader>d", group = "Diagnostics" },
    { "<leader>f", group = "Files / Find" },
    { "<leader>g", group = "Git" },
    { "<leader>t", group = "Tests" },
  })
end
