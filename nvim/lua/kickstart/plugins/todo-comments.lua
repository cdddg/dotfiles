-- Highlight todo, notes, etc in comments
return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
  version = 'v1.*',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = { signs = false },
}
-- vim: ts=2 sts=2 sw=2 et
