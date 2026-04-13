-- Bug: live_grep does not navigate to search result when file explorer is focused #1684
-- https://github.com/ibhagwan/fzf-lua/issues/1684
local function safe_fzf_search(fn)
  return function()
    if vim.bo.filetype == 'neo-tree' then
      vim.notify('Search is disabled in Neo-tree buffer', vim.log.levels.ERROR)
    else
      fn()
    end
  end
end

return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  cmd = 'FzfLua',
  keys = {
    { '<leader>sf', '<cmd>FzfLua files<cr>', desc = 'Search [f]iles' },
    {
      '<leader>sg',
      safe_fzf_search(function()
        require('fzf-lua').live_grep()
      end),
      desc = 'Search [g]rep',
    },
    {
      '<leader>sl',
      safe_fzf_search(function()
        local fzf = require 'fzf-lua'
        fzf.live_grep {
          prompt = 'Literal> ',
          rg_opts = '--fixed-strings ' .. fzf.config.globals.grep.rg_opts,
        }
      end),
      desc = 'Search by [l]iteral grep without regex',
    },
    { '<leader>/', '<cmd>FzfLua lgrep_curbuf<cr>', desc = 'Search current buffer' },
    { '<leader>sb', '<cmd>FzfLua dap_breakpoints<cr>', desc = 'Search DAP [b]reakpoints' },
  },
  init = function()
    -- Deferred ui_select: override vim.ui.select early so it works
    -- even before fzf-lua is loaded by a keymap or command.
    vim.ui.select = function(...)
      require('lazy').load { plugins = { 'fzf-lua' } }
      return vim.ui.select(...)
    end
  end,
  config = function(_, opts)
    local fzf = require 'fzf-lua'
    fzf.setup(opts)
    fzf.register_ui_select()
  end,
  opts = {
    'default',
    fzf_opts = {
      ['--history'] = vim.fn.stdpath 'data' .. '/fzf-lua-history',
    },
    keymap = {
      builtin = {
        true,
      },
      fzf = {
        true,
        ['tab'] = 'down',
        ['shift-tab'] = 'up',
        ['ctrl-p'] = 'previous-history',
        ['ctrl-n'] = 'next-history',
        ['ctrl-y'] = 'toggle',
      },
    },
    files = {
      hidden = true,
      file_ignore_patterns = { '%.git/' },
      winopts = { preview = { hidden = true } },
      line_query = true,
    },
    grep = {
      hidden = true,
      file_ignore_patterns = { '%.git/' },
      fzf_opts = {
        ['--delimiter'] = ':',
        ['--with-nth'] = '1,4..', -- 顯示 filename 和 content，跳過 line:column
      },
    },
    grep_curbuf = {
      winopts = { preview = { hidden = true } },
    },
  },
}
