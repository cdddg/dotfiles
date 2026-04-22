return {
  -- Fork of sindrets/diffview.nvim, which has been inactive since June 2024
  -- https://www.reddit.com/r/neovim/comments/1sl24gi/actively_maintained_fork_of_diffviewnvim/
  'dlyongemallo/diffview.nvim',
  version = 'v0.*',
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
    vim.api.nvim_set_keymap('n', '<leader>gdv', ':lua DiffviewOpenClose()<CR>', { noremap = true, silent = true })
  end,
  config = function()
    require('diffview').setup {
      enhanced_diff_hl = true,
    }
  end,
  keys = {
    { '<leader>gdv', ':lua DiffviewOpenClose()<CR>', mode = 'n', noremap = true, silent = true, desc = 'Git Diff[v]iew' },
  },
}
-- vim: ts=2 sts=2 sw=2 et
