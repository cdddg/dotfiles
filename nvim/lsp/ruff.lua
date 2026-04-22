---@type vim.lsp.Config
return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  capabilities = {
    offsetEncoding = { 'utf-16' },
  },
}
-- vim: ts=2 sts=2 sw=2 et
