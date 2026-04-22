-- Title: Lazy List Plugin Versions
-- Description: Echoes all installed plugins with their versions to the cmdline.

local M = {}

-- Nerd Font icon
local ICON_PLUG = ''

-- Pad `text` to exactly `width` display columns. Returns text unchanged if
-- already at or wider than `width` so callers retain the dynamic max width.
local function pad_to(text, width)
  local current = vim.fn.strdisplaywidth(text)
  if current >= width then
    return text
  end
  return text .. string.rep(' ', width - current)
end

-- Get current version/tag for a plugin
local function get_plugin_version(repo_path)
  -- Try to get exact tag first
  local cmd = { 'git', '-C', repo_path, 'describe', '--tags', '--exact-match' }
  local out = vim.fn.systemlist(cmd)
  if vim.v.shell_error == 0 and #out > 0 then
    return out[1]
  end

  -- Fallback to describe (tag + commit)
  cmd = { 'git', '-C', repo_path, 'describe', '--tags', '--always' }
  out = vim.fn.systemlist(cmd)
  if vim.v.shell_error == 0 and #out > 0 then
    return out[1]
  end

  return 'unknown'
end

function M.list()
  local plugins = require('lazy.core.config').plugins

  -- Collect all plugins with their versions
  local plugin_list = {}
  for _, p in pairs(plugins) do
    if p.dir and p[1] then
      table.insert(plugin_list, {
        name = p[1],
        version = get_plugin_version(p.dir),
        pinned = p.version or nil,
      })
    end
  end

  if #plugin_list == 0 then
    vim.notify('No plugins found', vim.log.levels.INFO)
    return
  end

  -- Sort by name
  table.sort(plugin_list, function(a, b)
    return a.name < b.name
  end)

  -- Dynamic max display widths for alignment
  local max_name_width, max_version_width = 0, 0
  for _, p in ipairs(plugin_list) do
    local nw = vim.fn.strdisplaywidth(p.name)
    local vw = vim.fn.strdisplaywidth(p.version)
    if nw > max_name_width then max_name_width = nw end
    if vw > max_version_width then max_version_width = vw end
  end

  -- Build echo chunks
  local chunks = {}
  local function add_line(line_chunks)
    for _, c in ipairs(line_chunks) do
      table.insert(chunks, c)
    end
    table.insert(chunks, { '\n' })
  end

  add_line { { ('Lazy Plugin List (%d)'):format(#plugin_list), 'Comment' } }
  add_line { { '' } }

  for _, p in ipairs(plugin_list) do
    -- Pinned → version + 🧊 share WarningMsg (matches copilot.lua's deprecation
    -- hint hue) since "locked, manual update required" is the same signal.
    local version_hl = p.pinned and 'WarningMsg' or 'Comment'
    local line = {
      { ICON_PLUG, 'Comment' },
      { ' ' },
      { pad_to(p.name, max_name_width) },
      { '  ' },
      { pad_to(p.version, max_version_width), version_hl },
    }
    if p.pinned then
      table.insert(line, { '  🧊', 'WarningMsg' })
    end
    add_line(line)
  end

  -- Drop trailing newline so the hit-enter prompt sits flush with the last line
  if chunks[#chunks] and chunks[#chunks][1] == '\n' then
    table.remove(chunks)
  end
  vim.api.nvim_echo(chunks, true, {})
end

-- Register as :Lazy list subcommand
vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyVimStarted',
  callback = function()
    local ok, commands = pcall(require, 'lazy.view.commands')
    if ok and commands.commands then
      commands.commands.list = M.list
    end
  end,
  once = true,
})

return M
-- vim: ts=2 sts=2 sw=2 et
