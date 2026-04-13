return {
  'sindrets/diffview.nvim',
  enabled = false,
  lazy = true,
  cmd = 'DiffviewOpen',
  requires = 'nvim-lua/plenary.nvim',
  init = function()
    _G.DiffviewOpenClose = function()
      local view = require('diffview.lib').get_current_view()
      if view then
        require('diffview').close()
      else
        require('diffview').open {}
      end
    end
    vim.api.nvim_set_keymap('n', '<leader>gd', ':lua DiffviewOpenClose()<CR>', { noremap = true, silent = true })
  end,
  config = function()
    require('diffview').setup {
      enhanced_diff_hl = true,
    }
  end,
  keys = {
    { '<leader>gd', ':lua DiffviewOpenClose()<CR>', mode = 'n', noremap = true, silent = true, desc = 'Git Diffview' },
  },
}
-- vim: ts=2 sts=2 sw=2 et
