return {
  'mrjones2014/smart-splits.nvim',
  version = 'v2.*',
  lazy = false, -- 確保一啟動就載入、也才會跑 build
  build = './kitty/install-kittens.bash',
  config = function()
    require('smart-splits').setup {
      at_edge = 'stop', -- default: 'wrap'
    }

    local smart_splits = require 'smart-splits'

    vim.keymap.set('n', '<M-h>', smart_splits.resize_left)
    vim.keymap.set('n', '<M-j>', smart_splits.resize_down)
    vim.keymap.set('n', '<M-k>', smart_splits.resize_up)
    vim.keymap.set('n', '<M-l>', smart_splits.resize_right)

    vim.keymap.set('n', '<C-h>', smart_splits.move_cursor_left)
    vim.keymap.set('n', '<C-j>', smart_splits.move_cursor_down)
    vim.keymap.set('n', '<C-k>', smart_splits.move_cursor_up)
    vim.keymap.set('n', '<C-l>', smart_splits.move_cursor_right)
    vim.keymap.set('n', '<C-\\>', smart_splits.move_cursor_previous)

    vim.keymap.set('n', '<leader><leader>h', smart_splits.swap_buf_left)
    vim.keymap.set('n', '<leader><leader>j', smart_splits.swap_buf_down)
    vim.keymap.set('n', '<leader><leader>k', smart_splits.swap_buf_up)
    vim.keymap.set('n', '<leader><leader>l', smart_splits.swap_buf_right)
  end,
}
-- vim: ts=2 sts=2 sw=2 et
