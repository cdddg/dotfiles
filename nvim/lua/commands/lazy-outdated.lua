-- Title: Lazy Outdated Plugin Tags
-- Description: Echoes up to 4 older tags, the current tag, and all newer tags for each versioned plugin to the cmdline.

local M = {}
local fn = vim.fn

-- Nerd Font icon for plugin title
local ICON_PLUG = ''

-- Highlight groups using Catppuccin Mocha palette.
-- To switch flavor: replace each hex with the same semantic name from the new flavor.
-- Palette reference: https://catppuccin.com/palette
local function setup_highlights()
  vim.api.nvim_set_hl(0, 'LazyOutdatedOld',     { fg = '#45475a' }) -- surface1
  vim.api.nvim_set_hl(0, 'LazyOutdatedCurrent', { fg = '#cdd6f4' }) -- text
  vim.api.nvim_set_hl(0, 'LazyOutdatedNew',     { fg = '#a6e3a1' }) -- green
  vim.api.nvim_set_hl(0, 'LazyOutdatedIcon',    { fg = '#f38ba8' }) -- red
end

setup_highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = setup_highlights,
})

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
    local body = {}
    local outdated_count = 0

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
        table.insert(body, {
          { ICON_PLUG, 'LazyOutdatedIcon' },
          { ' ' },
          { p[1], 'LazyOutdatedCurrent' },
          { (' (current: %s) 🆕'):format(current), 'LazyOutdatedCurrent' },
        })

        -- old tags
        for _, td in ipairs(old) do
          table.insert(body, {
            { ('  ● %-7s  %-7s  %s'):format(td.commit, td.tag, td.date), 'LazyOutdatedOld' },
          })
        end
        -- current tag
        for _, td in ipairs(all) do
          if td.tag == current then
            table.insert(body, {
              { ('  ● %-7s  %-7s  %s'):format(td.commit, td.tag, td.date), 'LazyOutdatedCurrent' },
            })
            break
          end
        end
        -- new tags
        for _, td in ipairs(new) do
          table.insert(body, {
            { ('  ● %-7s  %-7s  %s'):format(td.commit, td.tag, td.date), 'LazyOutdatedNew' },
          })
        end
        table.insert(body, { { '' } })
      end
    end

    -- Clear the "Fetching..." line before the next echo
    vim.api.nvim_echo({ { '' } }, false, {})

    -- If no outdated plugins, show message and return
    if outdated_count == 0 then
      vim.notify('All plugins are up to date! 🎉', vim.log.levels.INFO)
      return
    end

    -- Build echo chunks
    local chunks = {}
    local function add_line(line_chunks)
      for _, c in ipairs(line_chunks) do
        table.insert(chunks, c)
      end
      table.insert(chunks, { '\n' })
    end

    add_line { { ('Lazy Outdated Plugin Tags (%d)'):format(outdated_count) } }
    add_line { { 'Displays plugins with newer versions available.' } }
    add_line { { '' } }

    for _, line in ipairs(body) do
      add_line(line)
    end

    -- Drop trailing newline so the hit-enter prompt sits flush with the last line
    if chunks[#chunks] and chunks[#chunks][1] == '\n' then
      table.remove(chunks)
    end
    vim.api.nvim_echo(chunks, true, {})
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
