return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      {
        'jay-babu/mason-nvim-dap.nvim',
        version = 'v2.*',
        desc = 'Manages and installs DAP adapters via Mason (bridge between Mason and nvim-dap)',
      },
      {
        'igorlfs/nvim-dap-view',
        version = 'v1.*',
        desc = 'Unified DAP UI in a single window (variables, breakpoints, REPL, etc.)',
        opts = {
          auto_toggle = false,
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
        function()
          local dv = require 'dap-view'
          dv.toggle(true)
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'dap-view' then
              vim.api.nvim_set_current_win(win)
              return
            end
          end
        end,
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

      local dap = require 'dap'
      local dv = require 'dap-view'
      local function open_and_focus()
        dv.open()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'dap-view' then
            vim.api.nvim_set_current_win(win)
            return
          end
        end
      end
      dap.listeners.before.attach['dap-view'] = open_and_focus
      dap.listeners.before.launch['dap-view'] = open_and_focus
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
