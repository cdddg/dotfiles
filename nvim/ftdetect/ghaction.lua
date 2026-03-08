-- GitHub Actions workflow filetype detection
vim.filetype.add {
  pattern = {
    ['.*/.github/workflows/.*%.yml'] = 'ghaction',
    ['.*/.github/workflows/.*%.yaml'] = 'ghaction',
    ['.*/.github/actions/.*%.yml'] = 'ghaction',
    ['.*/.github/actions/.*%.yaml'] = 'ghaction',
  },
}

vim.treesitter.language.register('yaml', 'ghaction')
