return {
  'chentoast/marks.nvim',
  event = 'VeryLazy',
  opts = {
    default_mappings = true,
    builtin_marks = {
      '.', -- last change position (最後一次修改的位置)
      '<', -- start of last visual selection (上一次 visual 選取的起點)
      '>', -- end of last visual selection (上一次 visual 選取的終點)
      '^', -- last insert position (上一次離開 Insert mode 的位置)
    },
    sign_priority = {
      lower = 10, -- 小寫標記 a–z 的 priority, default=10
      upper = 15, -- 大寫標記 A–Z 的 priority, default=15
      builtin = 8, -- 內建那些「.」「<」「>」「^」的 priority, default=8
      bookmark = 20, -- 你如果開了 bookmarks（m1–m9）這些的 priority, default=20
    },
  },
  config = function(_, opts)
    require('marks').setup(opts)

    local function get_hl(name)
      return vim.api.nvim_get_hl(0, { name = name, link = false })
    end
    vim.api.nvim_set_hl(0, 'MarkSignHL', { fg = get_hl('MarkSignHL').fg, bold = true })
    vim.api.nvim_set_hl(0, 'MarkSignNumHL', { fg = get_hl('MarkSignNumHL').fg, bold = true })
    vim.api.nvim_set_hl(0, 'MarkVirtTextHL', { fg = get_hl('MarkVirtTextHL').fg, bold = true })

    vim.keymap.set('n', 'dm*', function()
      vim.cmd 'delmarks!'
      vim.cmd 'delmarks A-Z0-9'
    end, { noremap = true, silent = true, desc = 'dm* → Clear ALL marks' })
  end,
}
-- vim: ts=2 sts=2 sw=2 et
