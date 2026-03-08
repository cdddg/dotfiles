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
  --    require 'kickstart.plugins.gitsigns'  -- loads from lua/kickstart/plugins/gitsigns.lua
  --
  -- For more info: `:help lazy.nvim-🔌-plugin-spec`

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  require 'kickstart.plugins.blink-cmp', -- About Performant, batteries-included completion
  require 'kickstart.plugins.conform', -- Lightweight yet powerful formatter
  require 'kickstart.plugins.gitsigns',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.mini',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.nvim-dap',
  require 'kickstart.plugins.nvim-lint',
  require 'kickstart.plugins.nvim-lspconfig',
  require 'kickstart.plugins.nvim-treesitter', -- Nvim Treesitter configurations and abstraction layer
  require 'kickstart.plugins.todo-comments',
  require 'kickstart.plugins.which-key',

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  require 'supplement.colorscheme',
  require 'supplement.plugins.codediff',
  require 'supplement.plugins.fzf',
  require 'supplement.plugins.grug-far',
  require 'supplement.plugins.multicursor',
  require 'supplement.plugins.numb',
  require 'supplement.plugins.nvim-mark',
  require 'supplement.plugins.nvim-ufo',
  require 'supplement.plugins.outline',
  require 'supplement.plugins.precognition',
  require 'supplement.plugins.rainbow-csv',
  require 'supplement.plugins.smart-splits',
  require 'supplement.plugins.text-case',
  require 'supplement.plugins.trouble',
  require 'supplement.plugins.vim-kitty',
  require 'supplement.plugins.vim-python-pep8-indent',
  require 'supplement.plugins.vim-vindent',
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
