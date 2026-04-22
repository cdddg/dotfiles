---@type vim.lsp.Config
return {
  cmd = { 'helm_ls', 'serve' },
  filetypes = { 'helm' },
  root_markers = { 'Chart.yaml' },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
