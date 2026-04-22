---@type vim.lsp.Config
return {
  cmd = { 'nginx-language-server' },
  filetypes = { 'nginx' },
  root_markers = { 'nginx.conf', '.git' },
}
-- vim: ts=2 sts=2 sw=2 et
