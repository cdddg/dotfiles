return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    branch = 'main', -- 2025-05-18: nvim-treesitter.configs removed, use rewritten main branch
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' }, -- must match nvim-treesitter branch
    },
    config = function()
      local ts = require 'nvim-treesitter'

      ts.install {
        'bash',
        'c',
        'diff',
        'dockerfile',
        'go',
        'helm',
        'html',
        'ini',
        'json',
        'latex',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'toml',
        'typst',
        'vim',
        'vimdoc',
        'yaml',
      }

      require('nvim-treesitter-textobjects').setup {}

      local disable = {
        highlight = { 'ruby', 'csv' },
        indent = { 'ruby', 'csv', 'python' },
      }
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, ft = args.buf, vim.bo[args.buf].filetype
          if not vim.tbl_contains(disable.highlight, ft) then
            pcall(vim.treesitter.start, buf)
          end
          if not vim.tbl_contains(disable.indent, ft) then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      vim.treesitter.language.register('yaml', 'docker-compose')
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
