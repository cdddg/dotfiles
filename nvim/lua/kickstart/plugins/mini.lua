return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font, set_vim_settings = false }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- Override mode indicator: show "MultiCursor" when multiple cursors are present
      local default_section_mode = statusline.section_mode
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_mode = function(opts)
        -- Obtain the original mode string and highlight group
        local mode_str, mode_hl = default_section_mode(opts)
        -- Safely check for multicursor.nvim and active cursors
        local ok, mc = pcall(require, 'multicursor-nvim')
        if ok and mc.hasCursors() then
          if mc.cursorsEnabled() then
            short_mode = 'MC'
            long_mode = 'MutliCursor'
          else
            short_mode = 'MC-S'
            long_mode = 'MC-Select'
          end
          mode_str = statusline.is_truncated(opts.trunc_width) and short_mode or long_mode
          mode_hl = 'MiniStatuslineModeOther'
        end
        return mode_str, mode_hl
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
      require('mini.trailspace').setup()

      vim.o.laststatus = 3
      vim.o.shortmess = vim.o.shortmess .. 'S'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
