return {
  'johmsalas/text-case.nvim',
  event = 'VeryLazy',
  config = function()
    require('textcase').setup {
      default_keymappings_enabled = true,
      prefix = 'ga',
    }
  end,
  keys = {
    'ga',
  },
  cmd = {
    'Subs',
    'TextCaseStartReplacingCommand',
  },
}
-- vim: ts=2 sts=2 sw=2 et
