-- Tab Selector - Show tabs in a bottom split window with selection
local M = {}

-- Create bottom split window
local function create_bottom_win(lines)
  -- Calculate height (number of tabs + 1 for padding, max 10)
  local height = math.min(#lines, 10)

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'tab-selector')
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')

  -- Create bottom split window
  vim.cmd('botright ' .. height .. 'split')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_set_option(win, 'cursorline', true)
  vim.api.nvim_win_set_option(win, 'number', false)
  vim.api.nvim_win_set_option(win, 'relativenumber', false)
  vim.api.nvim_win_set_option(win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(win, 'wrap', false)

  return buf, win
end

-- Get tab information
local function get_tab_info()
  local tabs = vim.api.nvim_list_tabpages()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local tab_info = {}

  for i, tabpage in ipairs(tabs) do
    local wins = vim.api.nvim_tabpage_list_wins(tabpage)
    local buffers = {}

    for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      local bufname = vim.api.nvim_buf_get_name(buf)
      if bufname ~= '' then
        local filename = vim.fn.fnamemodify(bufname, ':t')
        if filename ~= '' then
          table.insert(buffers, filename)
        end
      end
    end

    local is_current = tabpage == current_tab
    table.insert(tab_info, {
      index = i,
      tabpage = tabpage,
      buffers = buffers,
      is_current = is_current,
    })
  end

  return tab_info
end

-- Format tab lines for display
local function format_tab_lines(tab_info)
  local lines = {}
  local tab_map = {} -- Maps line number to tab index

  for _, info in ipairs(tab_info) do
    local prefix = info.is_current and '▶ ' or '  '
    local tab_line = string.format('%sTab %d', prefix, info.index)

    if #info.buffers > 0 then
      tab_line = tab_line .. ': ' .. table.concat(info.buffers, ', ')
    else
      tab_line = tab_line .. ': [No buffers]'
    end

    table.insert(lines, tab_line)
    table.insert(tab_map, info.index)
  end

  return lines, tab_map
end

-- Show tab selector
function M.show()
  local tab_info = get_tab_info()
  local lines, tab_map = format_tab_lines(tab_info)

  local buf, win = create_bottom_win(lines)

  -- Set lines
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  -- Find current tab line
  local current_line = 1
  for i, info in ipairs(tab_info) do
    if info.is_current then
      current_line = i
      break
    end
  end
  vim.api.nvim_win_set_cursor(win, { current_line, 0 })

  -- Keymaps
  local function close_window()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function select_tab()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local selected_line = cursor[1]
    local tab_index = tab_map[selected_line]

    close_window()

    if tab_index then
      vim.cmd('tabn ' .. tab_index)
    end
  end

  local function delete_tab()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local selected_line = cursor[1]
    local tab_index = tab_map[selected_line]

    if tab_index and #tab_info > 1 then
      close_window()
      vim.cmd('tabclose ' .. tab_index)
      vim.defer_fn(M.show, 50) -- Reopen after deletion
    else
      vim.notify("Can't close the last tab", vim.log.levels.WARN)
    end
  end

  -- Navigation with Tab/S-Tab
  local function next_tab()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local current_line = cursor[1]
    if current_line < #lines then
      vim.api.nvim_win_set_cursor(win, { current_line + 1, 0 })
    end
  end

  local function prev_tab()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local current_line = cursor[1]
    if current_line > 1 then
      vim.api.nvim_win_set_cursor(win, { current_line - 1, 0 })
    end
  end

  -- Set keymaps
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set('n', '<CR>', select_tab, opts)
  vim.keymap.set('n', '<Space>', select_tab, opts)
  vim.keymap.set('n', 'o', select_tab, opts)
  vim.keymap.set('n', 'q', close_window, opts)
  vim.keymap.set('n', '<Esc>', close_window, opts)
  vim.keymap.set('n', 'd', delete_tab, opts)
  vim.keymap.set('n', 'x', delete_tab, opts)
  vim.keymap.set('n', '<Tab>', next_tab, opts)
  vim.keymap.set('n', '<S-Tab>', prev_tab, opts)

  -- Auto-close when cursor leaves the window
  local augroup = vim.api.nvim_create_augroup('TabSelectorAutoClose', { clear = true })
  vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
    group = augroup,
    buffer = buf,
    callback = function()
      close_window()
      vim.api.nvim_del_augroup_by_id(augroup)
    end,
  })

  -- Highlight current tab
  vim.api.nvim_buf_add_highlight(buf, -1, 'String', current_line - 1, 0, 2)
end

vim.api.nvim_create_user_command('Tabs', function()
  M.show()
end, { desc = 'Show tab selector in floating window' })

return M
