return {
  {
    'sindrets/diffview.nvim',
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
      local actions = require 'diffview.actions'
      require('diffview').setup {
        enhanced_diff_hl = true,
        -- keymaps = {
        --   view = {
        --     { 'n', '<leader>co', false },
        --     { 'n', '<leader>ct', false },
        --     { 'n', '<leader>cb', false },
        --     { 'n', '<leader>ca', false },
        --     { 'n', '<leader>cO', false },
        --     { 'n', '<leader>cT', false },
        --     { 'n', '<leader>cB', false },
        --     { 'n', '<leader>cA', false },
        --     { 'n', 'co', actions.conflict_choose 'ours', { desc = 'Choose the OURS version of a conflict' } },
        --     { 'n', 'ct', actions.conflict_choose 'theirs', { desc = 'Choose the THEIRS version of a conflict' } },
        --     { 'n', 'cb', actions.conflict_choose 'base', { desc = 'Choose the BASE version of a conflict' } },
        --     { 'n', 'ca', actions.conflict_choose 'all', { desc = 'Choose all the versions of a conflict' } },
        --     { 'n', 'cO', actions.conflict_choose_all 'ours', { desc = 'Choose the OURS version of a conflict for the whole file' } },
        --     { 'n', 'cT', actions.conflict_choose_all 'theirs', { desc = 'Choose the THEIRS version of a conflict for the whole file' } },
        --     { 'n', 'cB', actions.conflict_choose_all 'base', { desc = 'Choose the BASE version of a conflict for the whole file' } },
        --     { 'n', 'cA', actions.conflict_choose_all 'all', { desc = 'Choose all the versions of a conflict for the whole file' } },
        --   },
        --   file_panel = {
        --     { 'n', '<leader>cO', false },
        --     { 'n', '<leader>cT', false },
        --     { 'n', '<leader>cB', false },
        --     { 'n', '<leader>cA', false },
        --     { 'n', 'cO', actions.conflict_choose_all 'ours', { desc = 'Choose the OURS version of a conflict for the whole file' } },
        --     { 'n', 'cT', actions.conflict_choose_all 'theirs', { desc = 'Choose the THEIRS version of a conflict for the whole file' } },
        --     { 'n', 'cB', actions.conflict_choose_all 'base', { desc = 'Choose the BASE version of a conflict for the whole file' } },
        --     { 'n', 'cA', actions.conflict_choose_all 'all', { desc = 'Choose all the versions of a conflict for the whole file' } },
        --   },
        -- },
      }
    end,
    keys = {
      { '<leader>gd', ':lua DiffviewOpenClose()<CR>', mode = 'n', noremap = true, silent = true, desc = 'Git Diffview' },
    },
  },
  {
    'akinsho/git-conflict.nvim',
    event = 'BufReadPre',
    config = function()
      require('git-conflict').setup {
        -- highlights = {
        --   incoming = 'DiffText',
        --   current = 'DiffAdd',
        -- },
        disable_diagnostics = true, -- 如果你不想看到 LSP diagnostic 在衝突裡亂跳
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
