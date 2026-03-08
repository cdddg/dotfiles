return {
  'saghen/blink.cmp',
  event = 'VimEnter',
  version = '1.*',
  dependencies = {
    -- Snippet Engine
    {
      'L3MON4D3/LuaSnip',
      version = 'v2.*',
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      dependencies = {
        -- `friendly-snippets` contains a variety of premade snippets.
        --    See the README about individual language/framework/plugin snippets:
        --    https://github.com/rafamadriz/friendly-snippets
        -- {
        --   'rafamadriz/friendly-snippets',
        --   config = function()
        --     require('luasnip.loaders.from_vscode').lazy_load()
        --   end,
        -- },
      },
      opts = {},
    },
    { 'fang2hou/blink-copilot', version = 'v1.*' },
    'folke/lazydev.nvim',
  },
  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    enabled = function()
      return not vim.list_contains({ 'lazy', 'rip-substitute', 'DressingInput' }, vim.bo.filetype) and vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
    end,

    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      -- https://github.com/saghen/blink.cmp/blob/main/doc/blink-cmp.txt#L1676-L1763
      preset = 'none',
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<CR>'] = { 'select_and_accept', 'fallback' },
      ['<C-e>'] = { 'cancel', 'fallback' },
      ['<C-p>'] = { 'show', 'select_prev', 'fallback_to_mappings' },
      ['<C-n>'] = { 'show', 'select_next', 'fallback_to_mappings' },
      ['<C-y>'] = { 'select_and_accept' },
      ['<A-1>'] = {
        function(cmp)
          cmp.accept { index = 1 }
        end,
      },
      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      trigger = {
        show_on_x_blocked_trigger_characters = { '(' },
      },
      documentation = {
        auto_show = false,
      },
      list = {
        selection = { preselect = false, auto_insert = true },
      },

      -- how not to auto show ghost text when cursor moving after or before a character #1425
      -- https://github.com/Saghen/blink.cmp/issues/1425
      ghost_text = {
        enabled = true,
        show_with_selection = true, -- 有選中項目時也顯示
        show_without_selection = true, -- 沒選中時也顯示
        show_with_menu = true, -- 選單開啟時顯示
        show_without_menu = true, -- 選單關閉時也顯示
      },

      -- feature: select nth item in the completion list, and number items #382
      -- https://github.com/Saghen/blink.cmp/issues/382
      menu = {
        draw = {
          columns = { { 'item_idx' }, { 'kind_icon' }, { 'label', 'label_description', 'source_icon', gap = 2 } },
          components = {
            item_idx = {
              text = function(ctx)
                return tostring(ctx.idx)
              end,
              highlight = 'BlinkCmpItemIdx', -- optional, only if you want to change its color
            },
            source_icon = {
              text = function(ctx)
                local raw_key = ctx.source or ctx.source_name or ctx.label or '?'
                local key = string.lower(raw_key)
                local map = {
                  lsp = { icon = 'λ', label = 'LSP' },
                  snippets = { icon = ' ', label = 'Snip' },
                  path = { icon = '  ', label = 'Path' },
                  copilot = { icon = ' ', label = 'Copilot' },
                  lazydev = { icon = '󰚩', label = 'LazyDev' },
                }
                local entry = map[key] or { icon = '', label = raw_key }
                return string.format('%s', entry.icon)
              end,
              highlight = 'BlinkCmpSource', -- optional, only if you want to change its color
            },
          },
        },
      },
    },

    sources = {
      default = { 'copilot', 'lsp', 'snippets', 'path', 'lazydev' },
      providers = {
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 10 },
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 100,
          async = true,
          opts = {
            debounce = 100,
            max_completions = 5,
            max_attempts = 6, -- it is generally recommended to set it to max_completions+1.
          },
        },
      },
    },

    snippets = { preset = 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See :h blink-cmp-config-fuzzy for more information
    fuzzy = {
      implementation = 'prefer_rust_with_warning',
      -- sorts = {
      --   'score',
      --   'sort_text',
      --   'label',
      --   'kind',
      -- },
    },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = false },

    -- Cmdline completion (v1.7+)
    cmdline = {
      completion = {
        menu = { auto_show = true },
        list = {
          selection = { preselect = false, auto_insert = true },
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
