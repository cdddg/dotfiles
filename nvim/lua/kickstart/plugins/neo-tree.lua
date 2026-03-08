-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  lazy = true,
  cmd = 'Neotree',
  version = '3.*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  keys = {
    { '<leader>f', ':Neotree filesystem reveal=true toggle=true<CR>', desc = 'NeoTree [F]ilesystem' },
    -- { '<leader>b', ':Neotree buffers reveal=true toggle=true<CR>', desc = 'NeoTree [B]uffers' },
    { '<leader>gs', ':Neotree git_status reveal=true toggle=true<CR>', desc = 'NeoTree Git [s]tatus' },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        never_show = { '.DS_Store', '.git', '__pycache__', '.coverage' },
      },
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    buffers = {
      follow_current_file = { enabled = true },
    },
    window = {
      mappings = {
        ['<bs>'] = 'none',
        ['<CR>'] = 'none',
        ['oc'] = 'none',
        ['od'] = 'none',
        ['og'] = 'none',
        ['om'] = 'none',
        ['on'] = 'none',
        ['os'] = 'none',
        ['ot'] = 'none',
        ['u'] = 'navigate_up',
        ['o'] = 'open',
        ['O'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 'O' } },
        ['Oc'] = { 'order_by_created', nowait = false },
        ['Od'] = { 'order_by_diagnostics', nowait = false },
        ['Og'] = { 'order_by_git_status', nowait = false },
        ['Om'] = { 'order_by_modified', nowait = false },
        ['On'] = { 'order_by_name', nowait = false },
        ['Os'] = { 'order_by_size', nowait = false },
        ['Ot'] = { 'order_by_type', nowait = false },
      },
    },
    default_component_configs = {
      modified = {
        symbol = '󱙃 ',
        highlight = 'NeoTreeModified',
      },
      git_status = {
        symbols = {
          modified = '󰙏',
        },
      },
      symlink_target = { enabled = true },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
