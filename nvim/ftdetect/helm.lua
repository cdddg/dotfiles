-- Helm template filetype detection
vim.filetype.add {
  filename = {
    ['helmfile.yaml'] = 'helm',
    ['helmfile.yml'] = 'helm',
  },
  extension = {
    gotmpl = 'helm',
  },
  pattern = {
    ['.*/templates/.*%.yaml'] = 'helm',
    ['.*/templates/.*%.yml'] = 'helm',
    ['.*/templates/.*%.tpl'] = 'helm',
    ['.*helmfile.*%.yaml'] = 'helm',
    ['.*helmfile.*%.yml'] = 'helm',
  },
}
-- vim: ts=2 sts=2 sw=2 et