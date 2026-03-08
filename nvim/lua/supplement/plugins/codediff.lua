return {
  'esmuellert/codediff.nvim',
  version = 'v2.*',
  dependencies = { 'MunifTanjim/nui.nvim' },
  cmd = 'CodeDiff',
  opts = {
    explorer = {
      initial_focus = 'modified', -- Initial focus: "explorer", "original", or "modified"
      view_mode = 'tree',
    },
    keymaps = {
      view = {
        quit = 'q', -- Close diff tab
        toggle_explorer = '<leader>b', -- Toggle explorer visibility (explorer mode only)
        next_hunk = ']c', -- Jump to next change
        prev_hunk = '[c', -- Jump to previous change
        next_file = ']f', -- Next file in explorer/history mode
        prev_file = '[f', -- Previous file in explorer/history mode
        diff_get = 'do', -- Get change from other buffer (like vimdiff)
        diff_put = 'dp', -- Put change to other buffer (like vimdiff)
        open_in_prev_tab = 'gf', -- Open current buffer in previous tab (or create one before)
        toggle_stage = '-', -- Stage/unstage current file (works in explorer and diff buffers)
      },
      explorer = {
        select = 'o',
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
