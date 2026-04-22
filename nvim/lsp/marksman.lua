---@type vim.lsp.Config
return {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown', 'markdown.mdx' },
  root_markers = { '.marksman.toml', '.git' },
}
-- vim: ts=2 sts=2 sw=2 et
