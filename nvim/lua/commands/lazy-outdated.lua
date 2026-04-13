-- ver1-modified: ~/.config/nvim/lua/supplement/commands/lazy-outdated.lua
-- Title: Lazy Outdated Plugin Tags
-- Description: Displays up to 4 older tags, the current tag, and all newer tags for each versioned plugin in a split with aligned columns and color highlighting.

local M = {}
local fn = vim.fn

-- Nerd Font icon for plugin title
local ICON_PLUG = ''

-- Highlight groups using Catppuccin-Mocha palette
vim.cmd 'highlight LazyOutdatedOld guifg=#575268' -- surface1 (gray)
vim.cmd 'highlight LazyOutdatedCurrent guifg=#D9E0EE' -- text (whiteish)
vim.cmd 'highlight LazyOutdatedNew guifg=#A6E3A1' -- green
vim.cmd 'highlight LazyOutdatedIcon guifg=#F28FAD' -- red icon

-- Get current checked-out tag, strip 'v', fallback to p.version
local function get_current_tag(repo_path)
  local cmd = { 'git', '-C', repo_path, 'describe', '--tags', '--exact-match' }
  local out = fn.systemlist(cmd)
  if vim.v.shell_error == 0 and #out > 0 then
    return out[1]:gsub('^v', '')
  end
  return nil
end

-- Fetch all tags asynchronously
local function fetch_tag_date_list_async(repo_path, callback)
  vim.system({ 'git', '-C', repo_path, 'fetch', '--tags', '--prune' }, {}, function(fetch_result)
    if fetch_result.code ~= 0 then
      callback({})
      return
    end

    vim.system({
      'git',
      '-C',
      repo_path,
      'for-each-ref',
      '--sort=-creatordate',
      '--format=%(objectname:short)|%(refname:strip=2)|%(creatordate:iso8601)',
      'refs/tags',
    }, {}, function(result)
      if result.code == 0 and result.stdout then
        local lines = vim.split(result.stdout, '\n', { trimempty = true })
        callback(lines)
      else
        callback({})
      end
    end)
  end)
end

-- Parse raw git output
local function parse_tag_date(lines)
  local list = {}
  for _, line in ipairs(lines) do
    local commit, tag, date = line:match '([^|]+)|([^|]+)|(.+)'
    if commit and tag and date then
      table.insert(list, { commit = commit, tag = tag:gsub('^v', ''), date = date })
    end
  end
  return list
end

function M.check()
  local plugins = require('lazy.core.config').plugins

  -- Collect versioned plugins
  local versioned_plugins = {}
  for _, p in pairs(plugins) do
    if p.dir and p.version then
      table.insert(versioned_plugins, p)
    end
  end

  if #versioned_plugins == 0 then
    vim.notify('No versioned plugins found', vim.log.levels.INFO)
    return
  end

  vim.api.nvim_echo({ { string.format('⟳ Fetching tags for %d plugins...', #versioned_plugins), 'ModeMsg' } }, false, {})
  vim.cmd 'redraw'

  local results = {}
  local completed = 0

  local function render_results()
    local lines = {}
    local meta = {}
    local meta_icon = {}
    local outdated_count = 0

    -- Header lines
    table.insert(lines, 'Lazy Outdated Plugin Tags')
    table.insert(lines, 'Displays plugins with newer versions available.')
    table.insert(lines, '')

    for _, result in ipairs(results) do
      local p, all, current = result.plugin, result.tags, result.current

      -- find current index
      local idx
      for i, td in ipairs(all) do
        if td.tag == current then
          idx = i
          break
        end
      end
      idx = idx or (#all + 1)

      -- split
      local new = vim.list_slice(all, 1, idx - 1)
      local old = vim.list_slice(all, idx + 1, idx + 4)

      -- Only process plugins with new versions
      if #new > 0 then
        outdated_count = outdated_count + 1

        -- reverse for ascending order
        local function reverse(tbl)
          for i = 1, math.floor(#tbl / 2) do
            tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
          end
        end
        reverse(old)
        reverse(new)

        -- plugin title with 🆕 indicator
        local title_line = string.format('%s %s (current: %s) 🆕', ICON_PLUG, p[1], current)
        table.insert(lines, title_line)
        table.insert(meta, { row = #lines - 1, group = 'LazyOutdatedCurrent' })
        table.insert(meta_icon, { row = #lines - 1, col_end = fn.strdisplaywidth(ICON_PLUG) })

        -- old tags
        for _, td in ipairs(old) do
          local text = string.format('  ● %-7s  %-7s  %s', td.commit, td.tag, td.date)
          table.insert(lines, text)
          table.insert(meta, { row = #lines - 1, group = 'LazyOutdatedOld' })
        end
        -- current tag
        for _, td in ipairs(all) do
          if td.tag == current then
            local text = string.format('  ● %-7s  %-7s  %s', td.commit, td.tag, td.date)
            table.insert(lines, text)
            table.insert(meta, { row = #lines - 1, group = 'LazyOutdatedCurrent' })
            break
          end
        end
        -- new tags
        for _, td in ipairs(new) do
          local text = string.format('  ● %-7s  %-7s  %s', td.commit, td.tag, td.date)
          table.insert(lines, text)
          table.insert(meta, { row = #lines - 1, group = 'LazyOutdatedNew' })
        end
        table.insert(lines, '')
      end
    end

    -- If no outdated plugins, show message and return
    if outdated_count == 0 then
      vim.notify('All plugins are up to date! 🎉', vim.log.levels.INFO)
      return
    end

    -- Render split
    vim.cmd 'botright new'
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].filetype = 'lazyoutdated'
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })

    -- center header within 80 columns
    local width = vim.o.textwidth > 0 and vim.o.textwidth or 80
    for i, text in ipairs { lines[1], lines[2] } do
      local pad = math.max(0, math.floor((width - #text) / 2))
      vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { string.rep(' ', pad) .. text })
    end

    -- apply highlights for tags/text
    for _, m in ipairs(meta) do
      vim.api.nvim_buf_add_highlight(buf, -1, m.group, m.row, 0, -1)
    end
    -- apply red highlight for icons
    for _, io in ipairs(meta_icon) do
      vim.api.nvim_buf_add_highlight(buf, -1, 'LazyOutdatedIcon', io.row, 0, io.col_end)
    end

    vim.api.nvim_echo({ { '' } }, false, {})
  end

  -- Async fetch all plugins
  for _, p in ipairs(versioned_plugins) do
    local raw_ver = p.version:gsub('^v', '')
    local current = get_current_tag(p.dir) or raw_ver

    fetch_tag_date_list_async(p.dir, function(tag_lines)
      local all = parse_tag_date(tag_lines)
      table.insert(results, { plugin = p, tags = all, current = current })
      completed = completed + 1

      if completed == #versioned_plugins then
        vim.schedule(render_results)
      end
    end)
  end
end

-- Register command to Lazy
vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyVimStarted',
  callback = function()
    local ok, commands = pcall(require, 'lazy.view.commands')
    if ok then
      commands.commands.outdated = M.check
    end
  end,
  once = true,
})

return M
-- vim: ts=2 sts=2 sw=2 et
