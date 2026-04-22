-- -- Neo-tree is a Neovim plugin to browse the file system
-- -- https://github.com/nvim-neo-tree/neo-tree.nvim
return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>f', ':Neotree filesystem reveal=true toggle=true<CR>', desc = 'NeoTree [F]ilesystem' },
      -- { '<leader>b', ':Neotree buffers reveal=true toggle=true<CR>', desc = 'NeoTree [B]uffers' },
      { '<leader>gs', ':Neotree git_status reveal=true toggle=true<CR>', desc = 'NeoTree Git [s]tatus' },
    },
    opts = {
      enable_diagnostics = false,
      filesystem = {
        filtered_items = {
          visible = true,
          never_show = { '.DS_Store', '.git', '__pycache__', '.coverage' },
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ['oc'] = 'none',
            ['od'] = 'none',
            ['og'] = 'none',
            ['om'] = 'none',
            ['on'] = 'none',
            ['os'] = 'none',
            ['ot'] = 'none',
            ['u'] = 'navigate_up',
            ['o'] = 'open',
            ['gf'] = function(state)
              vim.ui.open(state.tree:get_node().path) -- 用系統預設 App 開啟
            end,
          },
        },
      },
      buffers = {
        follow_current_file = { enabled = true },
        window = {
          mappings = {
            ['oc'] = 'none',
            ['od'] = 'none',
            ['og'] = 'none',
            ['om'] = 'none',
            ['on'] = 'none',
            ['os'] = 'none',
            ['ot'] = 'none',
            ['u'] = 'navigate_up',
            ['o'] = 'open',
          },
        },
      },
      git_status = {
        window = {
          mappings = {
            ['oc'] = 'none',
            ['od'] = 'none',
            ['og'] = 'none',
            ['om'] = 'none',
            ['on'] = 'none',
            ['os'] = 'none',
            ['ot'] = 'none',
            ['u'] = 'navigate_up',
            ['o'] = 'open',
          },
        },
      },
      default_component_configs = {
        git_status = {
          symbols = {
            added = '',
            modified = '',
            conflict = '',
          },
        },
        symlink_target = { enabled = true },
      },
    },
  },
  {
    'antosha417/nvim-lsp-file-operations',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neo-tree/neo-tree.nvim', -- makes sure that this loads after Neo-tree.
    },
    config = function()
      require('lsp-file-operations').setup()
    end,
  },
  {
    's1n7ax/nvim-window-picker',
    version = '2.*',
    config = function()
      require('window-picker').setup {
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { 'terminal', 'quickfix' },
          },
        },
      }
    end,
  },
}
-- -- vim: ts=2 sts=2 sw=2 et
