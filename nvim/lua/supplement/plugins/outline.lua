return {
  'hedyhli/outline.nvim',
  lazy = true,
  cmd = { 'Outline', 'OutlineOpen' },
  keys = {
    { '<leader>so', '<cmd>Outline<CR>', desc = 'Search symbol [o]utline' },
  },
  opts = {
    outline_window = {
      position = 'right',
      width = 15,
    },
    outline_items = {
      auto_set_cursor = true,
      auto_update_events = {
        follow = { 'CursorMoved' },
      },
    },
    symbols = {
      icons = {
        Constant = { icon = '󰏿', hl = 'Constant' },
        Parameter = { icon = '󰏪', hl = 'Identifier' },
        Variable = { icon = '󰀫', hl = 'Constant' },
      },
    },
  },
  symbol_folding = {
    -- 預設開啟時，哪些層級以下先收合（1 通常很實用：root 展開、子層先折）
    autofold_depth = 1,

    auto_unfold = {
      -- 游標/焦點所在的 symbol（以及其上層路徑）自動展開
      hovered = true,

      -- “only” 模式：只保留與當前 hovered 相關的 root 展開，其它 root 自動收合
      only = true,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
