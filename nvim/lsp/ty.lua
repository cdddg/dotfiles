---@type vim.lsp.Config
return {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'ty.toml', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  settings = {
    ty = {
      disableLanguageServices = true,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
