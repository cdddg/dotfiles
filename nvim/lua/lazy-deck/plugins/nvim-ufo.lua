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
  config = function(_, opts)
    require('ufo').setup(opts)

    -- Strip ufo's autocmds that reset manual fold state, keep only BufWinEnter
    local ufo_gid = vim.api.nvim_create_augroup('Ufo', { clear = false })
    local ufo_event = require('ufo.lib.event')

    -- Remove: {BufWinEnter, TextChanged, BufWritePost} combined autocmd
    for _, ac in ipairs(vim.api.nvim_get_autocmds({ group = ufo_gid, event = 'BufWinEnter' })) do
      vim.api.nvim_del_autocmd(ac.id)
    end
    -- Remove: ModeChanged *:n autocmd
    for _, ac in ipairs(vim.api.nvim_get_autocmds({ group = ufo_gid, event = 'ModeChanged' })) do
      vim.api.nvim_del_autocmd(ac.id)
    end

    -- Re-register only BufWinEnter so folds are created when opening a buffer
    vim.api.nvim_create_autocmd('BufWinEnter', {
      group = ufo_gid,
      callback = function(ev)
        ufo_event:emit(ev.event, ev.buf)
      end,
    })
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
