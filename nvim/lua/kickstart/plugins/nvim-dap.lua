return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      {
        'jay-babu/mason-nvim-dap.nvim',
        desc = 'Manages and installs DAP adapters via Mason (bridge between Mason and nvim-dap)',
      },
      {
        'igorlfs/nvim-dap-view',
        desc = 'Unified DAP UI in a single window (variables, breakpoints, REPL, etc.)',
        opts = {
          auto_toggle = true,
          -- winbar = {
          --   controls = {
          --     enabled = true,
          --   },
          -- },
        },
      },
      {
        'theHamsta/nvim-dap-virtual-text',
        desc = 'Displays inline variable values during debugging',
      },
      {
        'Weissle/persistent-breakpoints.nvim',
        opts = { load_breakpoints_event = { 'BufReadPost' } },
      },
    },
    keys = {
      {
        '<F1>',
        function()
          require('dap').step_into()
        end,
        desc = 'Debug: Step Into',
      },
      {
        '<F2>',
        function()
          require('dap').step_over()
        end,
        desc = 'Debug: Step Over',
      },
      {
        '<F3>',
        function()
          require('dap').step_out()
        end,
        desc = 'Debug: Step Out',
      },
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'debug: start/continue',
      },
      {
        '<F7>',
        '<cmd>DapViewToggle!<cr>',
        desc = 'Debug: Toggle Dap View',
      },
      {
        '<leader>db',
        function()
          require('persistent-breakpoints.api').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle Breakpoint',
      },
      {
        '<leader>dB',
        function()
          require('persistent-breakpoints.api').set_conditional_breakpoint()
        end,
        desc = 'Debug: Set Conditional Breakpoint',
      },
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('mason-nvim-dap').setup {
        automatic_installation = true,
        handlers = {},
      }

      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '◐', texthl = 'DapBreakpointCondition' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DapBreakpointRejected' })
      vim.fn.sign_define('DapStopped', { text = '⮕', texthl = 'DapStopped', linehl = 'DapStoppedLine' })
    end,
  },
  {
    'mfussenegger/nvim-dap-python',
    ft = 'python',
    dependencies = { 'mfussenegger/nvim-dap', 'mason-org/mason.nvim' },
    config = function()
      local debugpy = require('mason-registry').get_package 'debugpy'
      if not debugpy:is_installed() then
        debugpy:install()
      end
      local debugpy_path = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
      require('dap-python').setup(debugpy_path)
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
