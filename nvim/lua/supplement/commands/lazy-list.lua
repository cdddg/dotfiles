-- Title: Lazy List Plugin Versions
-- Description: Displays all installed plugins with their versions in a split window

local M = {}

-- Nerd Font icon
local ICON_PLUG = ''

-- Setup highlight groups (called on ColorScheme to persist)
local function setup_highlights()
  vim.api.nvim_set_hl(0, 'LazyListPluginName', { fg = '#89B4FA' }) -- blue
  vim.api.nvim_set_hl(0, 'LazyListVersion', { fg = '#A6E3A1' }) -- green
  vim.api.nvim_set_hl(0, 'LazyListIcon', { fg = '#F28FAD' }) -- red
end

setup_highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = setup_highlights,
})

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
      local version = get_plugin_version(p.dir)
      table.insert(plugin_list, {
        name = p[1],
        version = version,
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

  -- Calculate max name length for alignment (byte length for ASCII names)
  local max_name_len = 0
  for _, p in ipairs(plugin_list) do
    if #p.name > max_name_len then
      max_name_len = #p.name
    end
  end

  -- Build output lines
  local lines = {}
  local highlights = {}

  -- Header
  table.insert(lines, 'Lazy Plugin List')
  table.insert(lines, string.format('Total: %d plugins', #plugin_list))
  table.insert(lines, '')

  -- Byte length of icon (for highlight positioning)
  local icon_bytes = #ICON_PLUG

  -- Plugin entries
  for _, p in ipairs(plugin_list) do
    local pin_indicator = p.pinned and ' 🧊' or ''
    local line = string.format('%s %-' .. max_name_len .. 's  %s%s',
      ICON_PLUG, p.name, p.version, pin_indicator)
    table.insert(lines, line)

    -- Store highlight positions (using byte offsets)
    local row = #lines - 1
    local name_start = icon_bytes + 1 -- after icon + space
    local name_end = name_start + max_name_len
    local version_start = name_end + 2 -- after 2 spaces

    table.insert(highlights, {
      row = row,
      col_start = 0,
      col_end = icon_bytes,
      group = 'LazyListIcon',
    })
    table.insert(highlights, {
      row = row,
      col_start = name_start,
      col_end = name_end,
      group = 'LazyListPluginName',
    })
    table.insert(highlights, {
      row = row,
      col_start = version_start,
      col_end = -1,
      group = 'LazyListVersion',
    })
  end

  -- Create split window
  vim.cmd 'botright new'
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'lazylist'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })

  -- gx to open plugin GitHub page
  vim.keymap.set('n', 'gx', function()
    local line = vim.api.nvim_get_current_line()
    local repo = line:match '[%w%-_.]+/[%w%-_.]+'
    if repo then
      local url = 'https://github.com/' .. repo
      vim.ui.open(url)
    end
  end, { buffer = buf, desc = 'Open plugin on GitHub' })

  -- Center header
  local width = vim.o.textwidth > 0 and vim.o.textwidth or 80
  for i, text in ipairs { lines[1], lines[2] } do
    local pad = math.max(0, math.floor((width - #text) / 2))
    vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { string.rep(' ', pad) .. text })
  end

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl.group, hl.row, hl.col_start, hl.col_end)
  end
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
