return {
  'johmsalas/text-case.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  event = 'VeryLazy',
  config = function()
    require('textcase').setup {
      default_keymappings_enabled = true,
      prefix = 'ga',
    }
    require('telescope').load_extension 'textcase'
  end,
  keys = {
    'ga',
    { 'ga.', '<cmd>TextCaseOpenTelescope<cr>', mode = { 'n', 'x' }, desc = 'TextCase Telescope' },
  },
  cmd = {
    'Subs',
    'TextCaseOpenTelescope',
    'TextCaseOpenTelescopeQuickChange',
    'TextCaseOpenTelescopeLSPChange',
    'TextCaseStartReplacingCommand',
  },
}
-- vim: ts=2 sts=2 sw=2 et
