return {
  'MagicDuck/grug-far.nvim',
  version = '1.*',
  dependencies = { 'nvim-web-devicons' },
  keys = {
    {
      '<leader>sr',
      function()
        require('grug-far').open()
      end,
      desc = 'Search and [R]eplace',
      mode = { 'n', 'v' },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
