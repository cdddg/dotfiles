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
  { import = 'lazy-deck.plugins' },
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
