return {
  {
    'tris203/precognition.nvim',
    event = 'VeryLazy',
    keys = {
      -- Toggle gutter hints (G, gg, {, })
      {
        '<leader>tg',
        function()
          vim.g.precognition_gutter_enabled = not vim.g.precognition_gutter_enabled

          local precog = require 'precognition'
          precog.hide()
          precog.setup(vim.g._precognition_get_current_config())

          local status = vim.g.precognition_gutter_enabled and 'enabled' or 'disabled'
          print('Precognition: Gutter hints ' .. status)
        end,
        desc = '[T]oggle precognition [g]utter hints',
      },

      -- Toggle inline hints (w, b, e, ^, $, etc.)
      {
        '<leader>ti',
        function()
          vim.g.precognition_inline_enabled = not vim.g.precognition_inline_enabled

          local precog = require 'precognition'
          precog.hide()
          precog.setup(vim.g._precognition_get_current_config())

          local status = vim.g.precognition_inline_enabled and 'enabled' or 'disabled'
          print('Precognition: Inline hints ' .. status)
        end,
        desc = '[T]oggle precognition [i]nline hints',
      },
    },

    -- User-tunable defaults (only change here)
    opts = function()
      -- State flags (default: gutter on, inline off)
      vim.g.precognition_gutter_enabled = true
      vim.g.precognition_inline_enabled = false

      -- Base configuration
      local base_config = {
        showBlankVirtLine = false,
        highlightColor = { link = 'MarkVirtTextHL' },
      }

      -- Single source of truth for hint sets
      local gutter_defs = {
        -- File boundaries
        gg = { text = 'gg', prio = 20 },
        G = { text = 'G', prio = 20 },

        -- Paragraph / block
        PrevParagraph = { text = '{', prio = 0 },
        NextParagraph = { text = '}', prio = 0 },

        -- Viewport anchors
        -- Not Implemented Yet: https://github.com/tris203/precognition.nvim/issues/7
        -- H = { text = 'H', prio = 7 },
        -- M = { text = 'M', prio = 7 },
        -- L = { text = 'L', prio = 7 },

        -- Search navigation
        -- Not Implemented Yet: ...
        -- n = { text = 'n', prio = 6 },
        -- N = { text = 'N', prio = 6 },
      }

      local inline_defs = {
        Caret = { text = '^', prio = 2 },
        Dollar = { text = '$', prio = 1 },
        MatchingPair = { text = '%', prio = 5 },
        Zero = { text = '0', prio = 1 },
        w = { text = 'w', prio = 10 },
        b = { text = 'b', prio = 9 },
        e = { text = 'e', prio = 8 },
        W = { text = 'W', prio = 7 },
        B = { text = 'B', prio = 6 },
        E = { text = 'E', prio = 5 },
      }

      -- Build "enabled/disabled" tables programmatically
      local function with_enabled(defs, enabled)
        local out = {}
        for k, v in pairs(defs) do
          out[k] = { text = v.text, prio = enabled and v.prio or 0 }
        end
        return out
      end

      -- Helper: build full config from current flags
      local function get_current_config()
        return vim.tbl_deep_extend('force', base_config, {
          startVisible = true,
          gutterHints = with_enabled(gutter_defs, vim.g.precognition_gutter_enabled),
          hints = with_enabled(inline_defs, vim.g.precognition_inline_enabled),
        })
      end

      -- Expose helper for keymaps (no globals besides vim.g flags)
      vim.g._precognition_get_current_config = get_current_config

      return get_current_config()
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
