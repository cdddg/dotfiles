---@param bufnr integer
---@param client vim.lsp.Client
local function sign_in(bufnr, client)
  client:request('signIn', vim.empty_dict(), function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end
    if result.command then
      local code = result.userCode
      vim.fn.setreg('+', code)
      vim.fn.setreg('*', code)
      local continue = vim.fn.confirm(
        'Copied your one-time code to clipboard.\nOpen the browser to complete the sign-in process?',
        '&Yes\n&No'
      )
      if continue == 1 then
        client:exec_cmd(result.command, { bufnr = bufnr }, function(cmd_err, cmd_result)
          if cmd_err then
            vim.notify(cmd_err.message, vim.log.levels.ERROR)
            return
          end
          if cmd_result.status == 'OK' then
            vim.notify('Signed in as ' .. cmd_result.user .. '.')
          end
        end)
      end
    end
    if result.status == 'PromptUserDeviceFlow' then
      vim.notify('Enter your one-time code ' .. result.userCode .. ' in ' .. result.verificationUri)
    elseif result.status == 'AlreadySignedIn' then
      vim.notify('Already signed in as ' .. result.user .. '.')
    end
  end)
end

---@param client vim.lsp.Client
local function sign_out(_, client)
  client:request('signOut', vim.empty_dict(), function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end
    if result.status == 'NotSignedIn' then
      vim.notify('Not signed in.')
    end
  end)
end

---@param client vim.lsp.Client
local function check_status(_, client)
  client:request('checkStatus', vim.empty_dict(), function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end
    vim.print(result)
    local status = (result and result.status) or '?'
    local user = (result and result.user) or 'unknown'
    vim.notify(
      ('Copilot status: %s (user: %s)\nFull payload printed to :messages'):format(status, user),
      vim.log.levels.INFO
    )
  end)
end

-- Pad `text` to `width` display columns (not bytes), always leaving at least 1
-- trailing space as a column separator. Uses strdisplaywidth so wide chars
-- (×, —, emoji…) align visually instead of by byte count.
local function pad_to(text, width)
  local current = vim.fn.strdisplaywidth(text)
  return text .. string.rep(' ', math.max(1, width - current))
end

local function format_model_chunks(m)
  local chunks = {}

  local state = m.modelPolicy and m.modelPolicy.state
  if state == 'enabled' then
    table.insert(chunks, { '✔', 'DiagnosticOk' })
  elseif state == 'disabled' then
    table.insert(chunks, { '✘', 'DiagnosticError' })
  else
    table.insert(chunks, { '•' })
  end
  table.insert(chunks, { ' ' })

  local name = m.modelName or m.id or '?'
  local tag_text
  if m.isChatDefault then
    tag_text = ' [default]'
  elseif m.isChatFallback then
    tag_text = ' [fallback]'
  elseif m.preview then
    tag_text = ' [preview]'
  end

  if m.modelFamily == 'auto' then
    table.insert(chunks, { pad_to(name, 22) })
    table.insert(chunks, { '(auto-select)' })
    return chunks
  end

  local name_visible = vim.fn.strdisplaywidth(name) + (tag_text and vim.fn.strdisplaywidth(tag_text) or 0)
  local name_pad = math.max(1, 22 - name_visible)
  table.insert(chunks, { name })
  if tag_text then
    table.insert(chunks, { tag_text, 'Special' })
  end
  table.insert(chunks, { string.rep(' ', name_pad) })

  local vendor = m.vendor or '—'
  table.insert(chunks, { pad_to(vendor, 14) })

  local billing = '—'
  if m.billing then
    billing = m.billing.isPremium and ('premium ×%s'):format(m.billing.multiplier or '?') or 'free'
  end
  table.insert(chunks, { pad_to(billing, 13) })

  local ctx = '—'
  local lim = m.capabilities and m.capabilities.limits
  if lim and lim.maxContextWindowTokens then
    ctx = ('%dk'):format(math.floor(lim.maxContextWindowTokens / 1000))
  end
  table.insert(chunks, { pad_to(ctx, 5) })

  if m.degradationReason then
    local date = m.degradationReason:match('(%d%d%d%d%-%d%d%-%d%d)')
    table.insert(chunks, { '  ⏳ ' .. (date or 'deprecation'), 'DiagnosticWarn' })
  end

  return chunks
end

---@param client vim.lsp.Client
local function list_models(_, client)
  client:request('copilot/models', vim.empty_dict(), function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end
    local models = (type(result) == 'table' and (result.models or result)) or {}
    if type(models) ~= 'table' or vim.tbl_isempty(models) then
      vim.notify('No Copilot models returned.', vim.log.levels.WARN)
      return
    end

    local inline, chat = {}, {}
    for _, m in ipairs(models) do
      if type(m) == 'table' then
        local scopes = m.scopes or {}
        table.insert(vim.tbl_contains(scopes, 'completion') and inline or chat, m)
      end
    end

    local chunks = {}
    local function add_line(line_chunks)
      for _, c in ipairs(line_chunks) do
        table.insert(chunks, c)
      end
      table.insert(chunks, { '\n' })
    end

    add_line {
      { ('Copilot models (%d)   '):format(#models) },
      { '✔', 'DiagnosticOk' },
      { '=enabled  ' },
      { '✘', 'DiagnosticError' },
      { '=disabled  ' },
      { '•=no policy' },
    }
    add_line { { '' } }

    add_line { { 'Inline completion:' } }
    if #inline > 0 then
      for _, m in ipairs(inline) do
        local line = { { '  ' } }
        vim.list_extend(line, format_model_chunks(m))
        add_line(line)
      end
    else
      add_line {
        { '  ⚠ ', 'DiagnosticError' },
        { 'no model with scope=completion — ghost-text inline suggestions will not work', 'DiagnosticError' },
      }
    end
    add_line { { '' } }
    if #chat > 0 then
      add_line { { 'Chat / Agent:' } }
      for _, m in ipairs(chat) do
        local line = { { '  ' } }
        vim.list_extend(line, format_model_chunks(m))
        add_line(line)
      end
    end

    if chunks[#chunks] and chunks[#chunks][1] == '\n' then
      table.remove(chunks)
    end
    vim.api.nvim_echo(chunks, true, {})
  end)
end

---@type vim.lsp.Config
return {
  cmd = { 'copilot-language-server', '--stdio' },
  root_markers = { '.git' },
  init_options = {
    editorInfo = {
      name = 'Neovim',
      version = tostring(vim.version()),
    },
    editorPluginInfo = {
      name = 'Neovim',
      version = tostring(vim.version()),
    },
  },
  settings = {
    telemetry = {
      telemetryLevel = 'all',
    },
  },
  handlers = {
    didChangeStatus = function(_, result)
      if type(result) ~= 'table' then
        return
      end
      local kind = result.kind or 'Normal'
      local message = result.message or ''
      if kind == 'Normal' and message == '' then
        return
      end
      local level = ({
        Error = vim.log.levels.ERROR,
        Warning = vim.log.levels.WARN,
        Inactive = vim.log.levels.INFO,
        Normal = vim.log.levels.INFO,
      })[kind] or vim.log.levels.INFO
      vim.notify(('Copilot [%s] %s'):format(kind, message), level)
    end,
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotSignIn', function()
      sign_in(bufnr, client)
    end, { desc = 'Sign in Copilot with GitHub' })
    vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotSignOut', function()
      sign_out(bufnr, client)
    end, { desc = 'Sign out Copilot with GitHub' })
    vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotStatus', function()
      check_status(bufnr, client)
    end, { desc = 'Check Copilot sign-in status & quota' })
    vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotModels', function()
      list_models(bufnr, client)
    end, { desc = 'List available Copilot models' })
  end,
}
-- vim: ts=2 sts=2 sw=2 et
