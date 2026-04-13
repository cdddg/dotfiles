return {
  'folke/trouble.nvim',
  lazy = true,
  -- version = 'v3.*', -- disabled: v3.7.2 tag not yet released, need main branch for nvim 0.12 compat fix
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    {
      '<leader>dd',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Trouble: Toggle [d]ocument diagnostics (current buffer)',
    },
    {
      '<leader>dw',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Trouble: Toggle [w]orkspace diagnostics (global)',
    },
    {
      '<leader>dq',
      '<cmd>Trouble quickfix toggle<cr>',
      desc = 'Trouble: Toggle [q]uickfix list',
    },
  },
  opts = {
    signs = {
      -- icons / text used for a diagnostic
      error = '✖',
      warning = '󱈸',
      hint = '⚑',
      information = 'ℹ',
      other = '⚙',
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
