-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
require('lazy').setup({
  -- NOTE: Plugins can be added in three ways:
  --
  -- 1. String (simplest):
  --    'tpope/vim-sleuth'
  --
  -- 2. Table (with options):
  --    {
  --      'owner/repo',
  --      opts = { ... },           -- passed to setup()
  --      event = 'VeryLazy',       -- lazy load trigger
  --      keys = { '<leader>x' },   -- keymap trigger
  --      dependencies = { ... },   -- required plugins
  --    }
  --
  -- 3. Module (separate file):
  --    require 'lazy-deck.plugins.gitsigns'  -- loads from lua/lazy-deck/plugins/gitsigns.lua
  --
  -- For more info: `:help lazy.nvim-🔌-plugin-spec`

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  require 'lazy-deck.colorscheme',
  require 'lazy-deck.plugins.blink-cmp',
  -- require 'lazy-deck.plugins.codediff', -- unused
  require 'lazy-deck.plugins.conform',
  require 'lazy-deck.plugins.diffview',
  require 'lazy-deck.plugins.inline-diff',
  require 'lazy-deck.plugins.fzf',

  -- GitConflictDetected error when disabling diagnostics on Neovim nightly #119; https://github.com/akinsho/git-conflict.nvim/issues/119
  require 'lazy-deck.plugins.git-conflict',

  require 'lazy-deck.plugins.gitsigns',
  require 'lazy-deck.plugins.grug-far',
  require 'lazy-deck.plugins.indent-line',
  require 'lazy-deck.plugins.mini',
  require 'lazy-deck.plugins.multicursor',
  require 'lazy-deck.plugins.neo-tree',
  require 'lazy-deck.plugins.numb',
  require 'lazy-deck.plugins.nvim-dap',
  require 'lazy-deck.plugins.nvim-lint',
  require 'lazy-deck.plugins.mason-lsp',
  require 'lazy-deck.plugins.nvim-mark',
  require 'lazy-deck.plugins.nvim-treesitter',
  require 'lazy-deck.plugins.nvim-ufo',
  require 'lazy-deck.plugins.outline',
  -- require 'lazy-deck.plugins.precognition', -- unused
  require 'lazy-deck.plugins.rainbow-csv',
  require 'lazy-deck.plugins.smart-splits',
  require 'lazy-deck.plugins.text-case',
  require 'lazy-deck.plugins.todo-comments',
  require 'lazy-deck.plugins.trouble',
  require 'lazy-deck.plugins.vim-kitty',
  require 'lazy-deck.plugins.vim-python-pep8-indent',
  require 'lazy-deck.plugins.vim-vindent',
  require 'lazy-deck.plugins.which-key',
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  rocks = { enabled = false },
})

-- vim: ts=2 sts=2 sw=2 et
