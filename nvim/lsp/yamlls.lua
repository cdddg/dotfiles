---@type vim.lsp.Config
return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab', 'yaml.helm-values' },
  root_markers = { '.git' },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      schemas = {
        ['https://json.schemastore.org/kustomization.json'] = 'kustomization.{yml,yaml}',
        ['https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json'] = '*.k8s.{yml,yaml}',
        ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*.{yml,yaml}',
        ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = 'docker-compose*.{yml,yaml}',
      },
      format = { enable = true },
      validate = true,
      completion = true,
    },
  },
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = true
  end,
}
-- vim: ts=2 sts=2 sw=2 et
