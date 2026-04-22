-- Diagnostic severity filter — cycle and persist across sessions.
-- Levels: HINT+ → INFO+ → WARN+ → ERROR
-- Keybinding: <leader>dl (configured in keymaps.lua)

local M = {}

local state_file = vim.fn.stdpath('data') .. '/diagnostic_level.txt'

local levels = {
  { name = 'HINT+', severity = { min = vim.diagnostic.severity.HINT }, hl = 'DiagnosticHint' },
  { name = 'INFO+', severity = { min = vim.diagnostic.severity.INFO }, hl = 'DiagnosticInfo' },
  { name = 'WARN+', severity = { min = vim.diagnostic.severity.WARN }, hl = 'DiagnosticWarn' },
  { name = 'ERROR', severity = { min = vim.diagnostic.severity.ERROR }, hl = 'DiagnosticError' },
}

local current_index = 1

local function load()
  local f = io.open(state_file, 'r')
  if not f then return end
  local name = f:read('*l')
  f:close()
  for i, level in ipairs(levels) do
    if level.name == name then
      current_index = i
      return
    end
  end
end

local function save()
  local f = io.open(state_file, 'w')
  if not f then return end
  f:write(levels[current_index].name)
  f:close()
end

local function apply()
  local sev = levels[current_index].severity
  local cfg = vim.diagnostic.config() or {}

  if type(cfg.virtual_text) == 'table' then
    cfg.virtual_text.severity = sev
  elseif cfg.virtual_text then
    cfg.virtual_text = { severity = sev }
  end

  if type(cfg.signs) == 'table' then
    cfg.signs.severity = sev
  elseif cfg.signs then
    cfg.signs = { severity = sev }
  end

  if type(cfg.underline) == 'table' then
    cfg.underline.severity = sev
  elseif cfg.underline then
    cfg.underline = { severity = sev }
  end

  vim.diagnostic.config(cfg)
end

--- Call after vim.diagnostic.config() in mason-lsp to restore persisted level.
function M.apply_persisted()
  load()
  apply()
end

--- Cycle to next level, apply, persist, and notify.
function M.cycle()
  current_index = (current_index % #levels) + 1
  apply()
  save()
  local level = levels[current_index]
  vim.api.nvim_echo({ { 'Diagnostic: ', 'Normal' }, { level.name, level.hl } }, true, {})
end

--- Return current level name (for statusline, etc.)
function M.get_current()
  return levels[current_index].name
end

--- Return current severity filter (for vim.diagnostic.jump, etc.)
function M.get_severity()
  return levels[current_index].severity
end

return M

-- vim: ts=2 sts=2 sw=2 et
