-- Alternatively, use `config = function() ... end` for full control over the configuration.
-- If you prefer to call `setup` explicitly, use:
--    {
--        'lewis6991/gitsigns.nvim',
--        config = function()
--            require('gitsigns').setup({
--                -- Your gitsigns configuration here
--            })
--        end,
--    }
--
-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`.
--
-- See `:help gitsigns` to understand what the configuration keys do
return {
  'lewis6991/gitsigns.nvim',
  version = 'v2.*',
  event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
  opts = {
    -- signs = {
    --   add = { text = '+' },
    --   change = { text = '~' },
    --   delete = { text = '_' },
    --   topdelete = { text = '‾' },
    --   changedelete = { text = '~' },
    -- },

    attach_to_untracked = true,
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`

    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = 100,
      ignore_whitespace = false,
      virt_text_priority = 100,
    },
    current_line_blame_formatter = ' <author>, <author_time:%Y-%m-%d>, <summary>',
    on_attach = function(bufnr)
      local gitsigns = require 'gitsigns'

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk('next', { target = 'all' })
        end
      end, { desc = 'Jump to next git [c]hange (including staged)' })

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk('prev', { target = 'all' })
        end
      end, { desc = 'Jump to previous git [c]hange (including staged)' })

      -- Visual mode mappings for hunk operations
      map('v', '<leader>ghs', function()
        gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, { desc = '[s]tage selected hunk' })
      map('v', '<leader>ghr', function()
        gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, { desc = '[r]eset selected hunk' })

      -- Normal mode mappings for individual hunk operations
      -- map('n', '<leader>ghs', gitsigns.stage_hunk, { desc = 'Stage current hunk' })
      -- map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = 'Reset current hunk' })
      -- map('n', '<leader>ghu', gitsigns.undo_stage_hunk, { desc = 'Undo staging of current hunk' })

      -- Normal mode mappings for buffer-wide operations
      -- map('n', '<leader>gbS', gitsigns.stage_buffer, { desc = 'Stage all changes in buffer' })
      -- map('n', '<leader>gbR', gitsigns.reset_buffer, { desc = 'Reset all changes in buffer' })

      -- Normal mode mappings for hunk viewing operations
      -- map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = 'Preview changes in current hunk' })
      map('n', '<leader>ghb', gitsigns.blame_line, { desc = 'Show [b]lame for current line' })
      map('n', '<leader>ghd', gitsigns.diffthis, { desc = 'Show [d]iff of current file' })
      map('n', '<leader>ghD', function()
        gitsigns.diffthis '@'
      end, { desc = 'Show [D]iff of current file with last commit' })

      -- Toggle features
      map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, { desc = 'Toggle [b]lame annotation on current line' })
      map('n', '<leader>gtd', function()
        gitsigns.toggle_word_diff()
        gitsigns.toggle_linehl()
      end, { desc = 'Toggle Git [d]etail view (deleted, word_diff, linehl)' })

      local nontext_hl = vim.api.nvim_get_hl(0, { name = 'NonText', link = false })
      vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', {
        fg = nontext_hl.fg,
        bg = nontext_hl.bg,
        bold = true,
      })

      local gitsigns_change_hl = vim.api.nvim_get_hl(0, { name = 'GitSignsChange' })
      vim.api.nvim_set_hl(0, 'GitSignsChangeLn', {
        fg = 'none',
        bg = '#5d430c',
      })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
