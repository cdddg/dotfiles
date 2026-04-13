return {
  'lukas-reineke/indent-blankline.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  version = 'v3.*',
  -- Enable `lukas-reineke/indent-blankline.nvim`
  -- See `:help ibl`
  main = 'ibl',
  opts = {
    indent = {
      char = { '╏', '┇', '┋', '╎', '┆', '┊' },
      -- char = { '╎', '┆', '┊' },
    },
    scope = {
      show_start = false,
      show_end = false,

      -- -- [Possible to highlight current indentation level only?](https://github.com/lukas-reineke/indent-blankline.nvim/issues/964)
      -- include = {
      --   node_type = { ["*"] = { "*" } },
      -- },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
