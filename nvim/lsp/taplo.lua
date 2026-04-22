---@type vim.lsp.Config
return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_markers = { '.taplo.toml', 'taplo.toml', '.git' },
}
-- vim: ts=2 sts=2 sw=2 et
