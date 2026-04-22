---@type vim.lsp.Config
return {
  cmd = { 'docker-compose-langserver', '--stdio' },
  filetypes = { 'docker-compose' },
  root_markers = { 'docker-compose.yaml', 'docker-compose.yml', 'compose.yaml', 'compose.yml' },
}
-- vim: ts=2 sts=2 sw=2 et
