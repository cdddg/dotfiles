-- Zsh configuration filetype detection
vim.filetype.add {
  extension = {
    zsh = 'zsh',
  },
  filename = {
    ['.zshrc'] = 'zsh',
    ['.zshenv'] = 'zsh',
    ['.zprofile'] = 'zsh',
    ['.zlogin'] = 'zsh',
    ['.zlogout'] = 'zsh',
    ['zshrc'] = 'zsh',
    ['zshenv'] = 'zsh',
    ['zprofile'] = 'zsh',
    ['zlogin'] = 'zsh',
    ['zlogout'] = 'zsh',
  },
}
-- vim: ts=2 sts=2 sw=2 et
