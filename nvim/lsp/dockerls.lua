---@type vim.lsp.Config
return {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'dockerfile' },
  root_markers = { 'Dockerfile' },
}
-- vim: ts=2 sts=2 sw=2 et
