return {
  'cvlmtg/inline-diff.nvim',
  cmd = 'InlineDiff',
  keys = {
    { '<leader>gdo', '<cmd>InlineDiff<cr>', desc = 'Toggle inline diff [o]verlay' },
  },
  opts = {},
  config = function(_, opts)
    require('inline-diff').setup(opts)

    -- inline-diff 預設把整行 diff 的 fg 強制設成黑/白，會蓋掉 syntax 高亮。
    -- 攔截它的 define()，跑完之後永遠把 fg 清掉，只保留 bg。
    local highlight = require('inline-diff.highlight')
    local original_define = highlight.define
    highlight.define = function()
      original_define()
      for _, name in ipairs({ 'InlineDiffAdd', 'InlineDiffDelete' }) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        vim.api.nvim_set_hl(0, name, { bg = hl.bg })
      end
    end
    highlight.define()
  end,
}
-- vim: ts=2 sts=2 sw=2 et
