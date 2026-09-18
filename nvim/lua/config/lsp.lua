--=========================================--
--==              MASON                  ==--
--==       LSP PACKAGE MANAGER           ==--
--==                                     ==--
--== installs:                           ==--
--==    - C#:  roslyn, csharpier         ==--
--==    - lua: lua_ls                    ==--
--=========================================--

require("mason").setup()

-- Runs whenever an LSP attaches to a buffer.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("paulocrab-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration") -- WARN: declaration, not definition

  end,
})

-- Each server's full config (cmd, filetypes, root_markers, settings, ...) lives in
-- its own file under lsp/<name>.lua (auto-loaded from runtimepath). This just enables them.
vim.lsp.enable({ "roslyn", "lua_ls" })
