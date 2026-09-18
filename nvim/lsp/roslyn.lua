-- Roslyn, unlike lua_ls, does not discover your project on its own: it needs an
-- explicit "solution/open" (or "project/open") notification after init, and it
-- pulls diagnostics rather than pushing them, so we have to ask it to refresh.
-- Ported from nvim-lspconfig's lsp/roslyn_ls.lua (Apache-2.0), which we don't
-- depend on as a plugin here.

local uv = vim.uv
local fs = vim.fs

local group = vim.api.nvim_create_augroup("paulocrab-roslyn", { clear = true })

---@param client vim.lsp.Client
---@param target string
local function on_init_sln(client, target)
  client:notify("solution/open", { solution = vim.uri_from_fname(target) })
end

---@param client vim.lsp.Client
---@param project_files string[]
local function on_init_project(client, project_files)
  client:notify("project/open", {
    projects = vim.tbl_map(function(file)
      return vim.uri_from_fname(file)
    end, project_files),
  })
end

---@param client vim.lsp.Client
local function refresh_diagnostics(client)
  local capabilities = vim
    .iter(client.dynamic_capabilities.capabilities.diagnosticProvider or {})
    :map(function(cap)
      return cap.registerOptions.identifier
    end)
    :totable()

  for buf, _ in pairs(client.attached_buffers) do
    if vim.api.nvim_buf_is_loaded(buf) then
      for _, cap in pairs(capabilities) do
        client:request(vim.lsp.protocol.Methods.textDocument_diagnostic, {
          identifier = cap,
          textDocument = vim.lsp.util.make_text_document_params(buf),
        }, nil, buf)
      end
    end
  end
end

---@param client vim.lsp.Client
---@param action table
local function apply_action(client, action)
  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
  end
  if action.command then
    client:exec_cmd(action.command)
  end
end

---@param client vim.lsp.Client
---@param command table
---@param bufnr integer
local function handle_fix_all_action(client, command, bufnr)
  local arg = command.arguments and command.arguments[1]
  if type(arg) ~= "table" then
    return
  end

  local flavors = arg.FixAllFlavors
  if type(flavors) ~= "table" or vim.tbl_isempty(flavors) then
    return
  end

  vim.ui.select(flavors, { prompt = "Fix All Scope:" }, function(chosen_scope)
    if not chosen_scope then
      return
    end
    client:request("codeAction/resolveFixAll", {
      title = command.title,
      data = arg,
      scope = chosen_scope,
    }, function(err, resolved)
      if not err and resolved then
        apply_action(client, resolved)
      end
    end, bufnr)
  end)
end

---@param bufname string
---@return boolean
local function is_decompiled(bufname)
  local _, endpos = bufname:find("[/\\]MetadataAsSource[/\\]")
  if endpos == nil then
    return false
  end
  return vim.fn.finddir(bufname:sub(1, endpos), uv.os_tmpdir()) ~= ""
end

return {
  cmd = { "roslyn-language-server", "--stdio" },

  cmd_env = {
    -- Fixes LSP navigation in decompiled files on systems with a symlinked TMPDIR (macOS)
    TMPDIR = vim.env.TMPDIR and vim.env.TMPDIR ~= "" and vim.fn.resolve(vim.env.TMPDIR) or nil,
  },

  filetypes = { "cs" },

  root_dir = function(bufnr, cb)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if is_decompiled(bufname) then
      local prev_buf = vim.fn.bufnr("#")
      local client = vim.lsp.get_clients({ name = "roslyn", bufnr = prev_buf ~= 1 and prev_buf or nil })[1]
      if client then
        cb(client.config.root_dir)
      end
      return
    end

    local root_dir = fs.root(bufnr, function(fname)
      return fname:match("%.sln[x]?$") ~= nil
    end)
    if not root_dir then
      root_dir = fs.root(bufnr, function(fname)
        return fname:match("%.csproj$") ~= nil
      end)
    end
    if root_dir then
      cb(root_dir)
    end
  end,

  on_init = function(client)
    local root_dir = client.config.root_dir

    for entry, kind in fs.dir(root_dir) do
      if kind == "file" and (vim.endswith(entry, ".sln") or vim.endswith(entry, ".slnx")) then
        on_init_sln(client, fs.joinpath(root_dir, entry))
        return
      end
    end

    local projects = {}
    for entry, kind in fs.dir(root_dir) do
      if kind == "file" and vim.endswith(entry, ".csproj") then
        table.insert(projects, fs.joinpath(root_dir, entry))
      end
    end
    if #projects > 0 then
      on_init_project(client, projects)
    end
  end,

  on_attach = function(client, bufnr)
    if vim.api.nvim_get_autocmds({ buffer = bufnr, group = group })[1] then
      return
    end
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = group,
      buffer = bufnr,
      callback = function()
        refresh_diagnostics(client)
      end,
      desc = "roslyn: refresh diagnostics",
    })
  end,

  handlers = {
    ["workspace/projectInitializationComplete"] = function(_, _, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      refresh_diagnostics(client)
      return vim.NIL
    end,

    ["roslyn.client.nestedCodeAction"] = function(command, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      local arg = command.arguments and command.arguments[1]
      if type(arg) ~= "table" then
        return
      end

      local function handle(action)
        if not action then
          return
        end
        if action.data and not action.edit and not action.command then
          client:request("codeAction/resolve", action, function(err, resolved)
            if not err and resolved then
              handle(resolved)
            end
          end, ctx.bufnr)
          return
        end

        local nested = vim.islist(action) and action or action.NestedCodeActions
        if type(nested) ~= "table" or vim.tbl_isempty(nested) then
          apply_action(client, action)
          return
        end
        if #nested == 1 then
          handle(nested[1])
          return
        end

        vim.ui.select(nested, {
          prompt = action.title or "Select code action",
          format_item = function(item)
            return item.title or (item.command and item.command.title) or "Unnamed action"
          end,
        }, function(choice)
          if choice then
            handle(choice)
          end
        end)
      end

      handle(arg)
    end,

    ["roslyn.client.fixAllCodeAction"] = function(command, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      handle_fix_all_action(client, command, ctx.bufnr)
    end,
  },

  capabilities = {
    -- Roslyn won't report any diagnostics unless this is set.
    textDocument = {
      diagnostic = { dynamicRegistration = true },
    },
  },

  settings = {
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "fullSolution",
      dotnet_compiler_diagnostics_scope = "fullSolution",
    },
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ["csharp|symbol_search"] = {
      dotnet_search_reference_assemblies = true,
    },
    ["csharp|completion"] = {
      dotnet_show_name_completion_suggestions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_provide_regex_completions = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
  },
}
