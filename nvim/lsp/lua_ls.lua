return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },

  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = false -- formatting is done by stylua

    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath("config") and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) then
        return
      end
    end

    local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
    client.config.settings.Lua = vim.tbl_deep_extend("force", current_settings.Lua, {
      runtime = {
        version = "LuaJIT",
        path = { "lua/?.lua", "lua/?/init.lua" },
      },
      workspace = {
        checkThirdParty = false,
        -- Just Neovim's own runtime, not the whole of runtimepath (every
        -- plugin) - that's much slower to index and starves completion.
        -- https://github.com/neovim/nvim-lspconfig/issues/3189
        library = { vim.env.VIMRUNTIME },
      },
    })
  end,

  ---@type lspconfig.settings.lua_ls
  settings = {
    Lua = {
      format = { enable = false }, -- formatting is done by stylua
    },
  },
}
