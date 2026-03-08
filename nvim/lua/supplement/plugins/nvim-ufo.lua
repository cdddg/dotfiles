return {
  'kevinhwang91/nvim-ufo',
  event = 'VeryLazy', -- https://github.com/kevinhwang91/nvim-ufo/issues/47#issuecomment-1460742987
  dependencies = {
    'kevinhwang91/promise-async',
  },
  init = function()
    vim.o.foldcolumn = '0'
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    vim.keymap.set('n', 'z0', 'zR', { noremap = true, silent = true })
    vim.keymap.set('n', 'z1', 'zM', { noremap = true, silent = true })
    for i = 2, 9 do
      vim.keymap.set('n', 'z' .. i, function()
        vim.wo.foldlevel = i - 1
      end, { desc = 'Set fold level to ' .. i })
    end
  end,
  opts = {
    provider_selector = function(bufnr, filetype, buftype)
      local exclude = { 'codediff', 'codediff-explorer', 'codediff-history' }
      if vim.tbl_contains(exclude, filetype) then
        return ''
      end
      return { 'treesitter', 'indent' }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
