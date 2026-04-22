-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Highlight word under cursor without jumping to next match
vim.keymap.set('n', '*', function()
  local word = vim.fn.expand '<cword>'
  vim.fn.setreg('/', [[\<]] .. word .. [[\>]])
  vim.o.hlsearch = true
end, { noremap = true, silent = true, desc = 'Highlight word under cursor without moving' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, severity = require('diagnostics').get_severity() }
end, { desc = 'Go to previous [d]iagnostic message' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, severity = require('diagnostics').get_severity() }
end, { desc = 'Go to next [d]iagnostic message' })
vim.keymap.set('n', '<leader>dl', function()
  require('diagnostics').cycle()
end, { desc = 'Cycle diagnostic [l]evel filter' })
vim.keymap.set('n', '<leader>de', function()
  if vim.diagnostic then
    vim.diagnostic.open_float(nil, { focusable = true, severity = require('diagnostics').get_severity() })
  else
    print 'No diagnostics available.'
  end
end, { desc = 'Show diagnostic [e]rror messages' })
-- vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [q]uickfix list' })  -- use 'supplement/plugins/trouble.lua' instead

-- NOTE: Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
-- This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Jump list navigation
vim.keymap.set('n', '[j', '<C-o>', { desc = 'Jump back in [j]ump list' })
vim.keymap.set('n', ']j', '<C-i>', { desc = 'Jump forward in [j]ump list' })

-- Common remaps
vim.keymap.set('n', 'U', '<C-R>')
vim.keymap.set('i', 'jk', '<Esc>')

-- [[ Advanced Keymaps ]]
--
local last_paste = nil
local function paste_and_snapshot(cmd)
  vim.cmd('normal! ' .. cmd)
  last_paste = {
    buf = vim.api.nvim_get_current_buf(),
    start = vim.fn.getpos "'[",
    finish = vim.fn.getpos "']",
  }
end

-- Move selected lines
vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv", { silent = true, noremap = true, desc = 'Move up' })
vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv", { silent = true, noremap = true, desc = 'Move down' })

-- Enhanced yank
vim.keymap.set('x', 'Y', 'Y$', { noremap = true, silent = true, desc = 'Yank from cursor to end of line' })
vim.keymap.set('v', 'y', 'myy`y', { noremap = true, silent = true, desc = 'Yank and return to original cursor' })

-- Paste with snapshot (for gV to select last pasted text)
-- stylua: ignore start
vim.keymap.set('n', 'p', function() paste_and_snapshot '"+p`]' end)
vim.keymap.set('n', 'P', function() paste_and_snapshot '"+P`]' end)
vim.keymap.set('x', 'p', function() paste_and_snapshot '"+P`]' end) -- https://stackoverflow.com/a/73258457
vim.keymap.set('x', 'P', function() paste_and_snapshot '"+P`]' end)
-- stylua: ignore end

-- Delete to black hole register
vim.keymap.set({ 'n', 'x' }, 'x', '"_x')

-- Select all lines
-- NOTE: `ag` shadows mini.ai's generic "pair of g" textobj (rarely used in practice);
-- side effect is a timeoutlen wait on v{a,i}<x> when the next key is pressed slowly.
vim.keymap.set('x', 'ag', '<Esc>ggVG$', { noremap = true, silent = true, desc = 'Select all' })

-- Select last pasted text
vim.keymap.set('n', 'gV', function()
  if not last_paste then
    return
  end
  if vim.api.nvim_get_current_buf() ~= last_paste.buf then
    vim.notify('Last paste was in another buffer', vim.log.levels.WARN)
    return
  end
  vim.fn.setpos('.', last_paste.start)
  vim.cmd 'normal! v'
  vim.fn.setpos('.', last_paste.finish)
end, { desc = 'Select last pasted text' })

-- Remove 2 leading spaces from selected lines
vim.keymap.set('x', 'g<', function()
  local start_line = vim.fn.line 'v'
  local end_line = vim.fn.line '.'
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local pos = vim.fn.getpos '.'
  local line = vim.fn.getline(pos[2])
  local had_spaces = line:match '^  ' ~= nil

  vim.cmd(start_line .. ',' .. end_line .. 's/^  //e')

  if had_spaces then
    pos[3] = math.max(1, pos[3] - 2)
  end
  vim.fn.setpos('.', pos)
end, { desc = 'Remove 2 leading spaces from every selected line' })

-- A in visual-line mode appends at EOL
vim.keymap.set('x', 'A', function()
  if vim.fn.visualmode() == 'V' then
    return '<Esc>$a'
  end
  return 'A'
end, { expr = true, noremap = true, desc = 'A in visual-line mode appends at EOL' })

-- Interactive replace selected text
local function replace_selected_in_buffer()
  vim.cmd 'normal! "zy'

  local search = vim.fn.escape(vim.fn.getreg 'z', '\\/.*$^~[]%#')
  local cmd = ':%s/' .. search .. '//gc<Left><Left><Left>'
  local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)

  vim.api.nvim_feedkeys(keys, 'n', false)
end

vim.keymap.set('v', 'grs', replace_selected_in_buffer, { silent = true, desc = 'Replace selected text (interactive)' })

-- Replace selected text with clipboard content
local function replace_selected_with_clipboard()
  vim.cmd 'normal! "zy'

  local search = vim.fn.escape(vim.fn.getreg 'z', '\\/.*$^~[]%#')
  local replace = vim.fn.escape(vim.fn.getreg '+', '\\/.*$^~[]%#')
  local cmd = ':%s/' .. search .. '/' .. replace .. '/gc'

  vim.schedule(function()
    local keys = vim.api.nvim_replace_termcodes(cmd .. '<CR>', true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)
  end)
end

vim.keymap.set('v', 'grp', replace_selected_with_clipboard, { silent = true, desc = 'Replace with clipboard (interactive)' })

-- Yank or copy floating window content
local function yank_or_copy_float()
  local float_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= '' then
      float_win = win
      break
    end
  end

  if float_win then
    local cur_win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(float_win)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    vim.fn.setreg('+', table.concat(lines, '\n'))
    vim.notify('Copied content from floating window!', vim.log.levels.INFO, { title = 'Yank' })

    vim.api.nvim_win_close(float_win, true)
    vim.api.nvim_set_current_win(cur_win)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('y', true, false, true), 'n', false)
  end
end

vim.keymap.set('n', 'y', yank_or_copy_float, { noremap = true, silent = true, desc = 'Yank or copy floating window' })

-- Smart indent (cursor stays at same text position)
local function smart_indent(direction, mode)
  if not vim.bo.modifiable then
    return
  end

  local win = 0
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(win))

  local indent_before = vim.fn.indent(line)

  if mode == 'v' then
    vim.cmd('normal! ' .. ((direction == 'left') and '<' or '>') .. 'gv')
  else
    vim.cmd('normal! ' .. ((direction == 'left') and '<<' or '>>'))
  end

  local indent_after = vim.fn.indent(line)
  local indent_delta = indent_after - indent_before

  vim.api.nvim_win_set_cursor(win, { line, math.max(0, col + indent_delta) })
end

vim.keymap.set('n', '<Tab>', function()
  smart_indent 'right'
end)
vim.keymap.set('n', '<S-Tab>', function()
  smart_indent 'left'
end)
vim.keymap.set('v', '<Tab>', function()
  smart_indent('right', 'v')
end)
vim.keymap.set('v', '<S-Tab>', function()
  smart_indent('left', 'v')
end)

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
--

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et
