-- ~/.config/nvim/lua/plugins/vindent.lua
return {
  -- vindent.vim - Indent-based text objects and motions
  {
    'jessekelighine/vindent.vim',
    event = 'BufReadPre',
    lazy = true,
    init = function()
      -- ■ Motion 映射（jump to…）
      vim.g.vindent_motion_OO_prev = '[=' -- prev block same indent
      vim.g.vindent_motion_OO_next = ']=' -- next block same indent
      vim.g.vindent_motion_more_prev = '[+' -- prev line more indent
      vim.g.vindent_motion_more_next = ']+' -- next line more indent
      vim.g.vindent_motion_less_prev = '[-' -- prev line less indent
      vim.g.vindent_motion_less_next = ']-' -- next line less indent
      vim.g.vindent_motion_diff_prev = '[;' -- prev line different indent
      vim.g.vindent_motion_diff_next = '];' -- next line different indent
      vim.g.vindent_motion_XX_ss = '[p' -- jump to start of current block
      vim.g.vindent_motion_XX_se = ']p' -- jump to end   of current block

      -- ■ Text-Object 映射（select…）
      vim.g.vindent_object_XX_ii = 'ii' -- select inner indent block
      vim.g.vindent_object_XX_ai = 'ai' -- select indent block + the line above
      vim.g.vindent_object_XX_aI = 'aI' -- select indent block + one line above & below

      -- ■ 進階選項
      vim.g.vindent_jumps = 1 -- motion 也加入 jump list
      vim.g.vindent_begin = 1 -- 跳轉後移到行首（default:1）
      vim.g.vindent_count = 1 -- 支援 count 層級（default:1）
      vim.g.vindent_noisy = 0 -- 對不到目標行不報錯
      vim.g.vindent_infer = 1 -- 空行自動推斷縮排
      vim.g.vindent_block_ending = { 'end', 'else', 'elif', '}', ')', ']' }
    end,
  },

  -- vindent-marks - Gutter signs for vindent jump targets
  {
    dir = vim.fn.stdpath 'config',
    name = 'vindent-marks',
    event = 'BufReadPre',
    dependencies = { 'jessekelighine/vindent.vim' },

    keys = {
      -- Toggle vindent gutter jump hints ([=, ]=)
      {
        '<leader>tv',
        '<cmd>VindentSigns<CR>',
        desc = '[T]oggle [v]indent signs',
      },
    },

    -- User-tunable knobs (no config changes needed)
    opts = {
      enabled = false, -- default OFF
      priority = 100, -- sign priority
    },

    config = function(_, opts)
      local M = {}

      -- Options (from opts)
      opts = opts or {}
      local DEFAULT_ENABLED = opts.enabled == true
      local SIGN_PRIORITY = tonumber(opts.priority) or 100

      -- State
      local visible = false
      local dirty = false
      local gutter_group = 'vindent_gutter'
      local gutter_signs_cache = {}
      local augroup_id = nil

      -- Sign definitions (what you show in the gutter)
      local sign_configs = {
        SameIndentPrev = { text = '[=', hl = 'MarkVirtTextHL' },
        SameIndentNext = { text = ']=', hl = 'MarkVirtTextHL' },
        -- Optional (requires enabling corresponding build logic)
        -- MoreIndentPrev = { text = '[+', hl = 'MarkVirtTextHL' },
        -- MoreIndentNext = { text = ']+', hl = 'MarkVirtTextHL' },
        -- LessIndentPrev = { text = '[-', hl = 'MarkVirtTextHL' },
        -- LessIndentNext = { text = ']-', hl = 'MarkVirtTextHL' },
        -- DiffIndentPrev = { text = '[;', hl = 'MarkVirtTextHL' },
        -- DiffIndentNext = { text = '];', hl = 'MarkVirtTextHL' },
        -- BlockStart = { text = '[p', hl = 'MarkVirtTextHL' },
        -- BlockEnd = { text = ']p', hl = 'MarkVirtTextHL' },
      }

      -- Define all signs once
      for hint_name, config in pairs(sign_configs) do
        vim.fn.sign_define('vindent_' .. hint_name, {
          text = config.text,
          texthl = config.hl,
        })
      end

      -- Get indent level for a line
      local function get_indent(lnum)
        local line = vim.fn.getline(lnum)
        if line:match '^%s*$' then
          return -1
        end
        return vim.fn.indent(lnum)
      end

      -- Build vindent hints (jump targets) for the current cursor line
      local function build_vindent_hints()
        local bufnr = vim.api.nvim_get_current_buf()
        if not vim.bo[bufnr].modifiable or vim.bo[bufnr].buftype ~= '' then
          return {}
        end

        local total_lines = vim.fn.line '$'
        if total_lines > 5000 then
          return {}
        end

        local curline = vim.fn.line '.'
        local cur_indent = get_indent(curline)
        if cur_indent == -1 then
          return {}
        end

        local hints = {}

        -- Group 1: SameIndent
        for lnum = curline - 1, 1, -1 do
          local indent = get_indent(lnum)
          if indent ~= -1 and indent == cur_indent then
            hints.SameIndentPrev = lnum
            break
          end
        end

        for lnum = curline + 1, total_lines do
          local indent = get_indent(lnum)
          if indent ~= -1 and indent == cur_indent then
            hints.SameIndentNext = lnum
            break
          end
        end

        return hints
      end

      -- Apply gutter signs for hints
      local function apply_gutter_hints(hints, bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()

        -- Remove stale / moved signs
        for hint_name, cache_data in pairs(gutter_signs_cache) do
          local new_lnum = hints[hint_name]
          if not new_lnum or new_lnum == 0 or new_lnum ~= cache_data.line then
            vim.fn.sign_unplace(gutter_group, { id = cache_data.id })
            gutter_signs_cache[hint_name] = nil
          end
        end

        -- Place new / updated signs
        for hint_name, lnum in pairs(hints) do
          if lnum and lnum > 0 and sign_configs[hint_name] then
            if gutter_signs_cache[hint_name] and gutter_signs_cache[hint_name].line == lnum then
              goto continue
            end

            local sign_name = 'vindent_' .. hint_name
            local ok, id = pcall(vim.fn.sign_place, 0, gutter_group, sign_name, bufnr, {
              lnum = lnum,
              priority = SIGN_PRIORITY,
            })

            if ok then
              gutter_signs_cache[hint_name] = { line = lnum, id = id }
            end

            ::continue::
          end
        end
      end

      local function clear_all()
        gutter_signs_cache = {}
        vim.fn.sign_unplace(gutter_group)
      end

      local function redraw()
        if not visible or not dirty then
          return
        end
        apply_gutter_hints(build_vindent_hints())
        dirty = false
      end

      local function on_cursor_moved()
        dirty = true
        redraw()
      end

      local function on_buf_enter()
        dirty = true
        redraw()
      end

      local function on_buf_leave()
        clear_all()
        dirty = true
      end

      function M.show()
        if visible then
          return
        end
        visible = true

        augroup_id = vim.api.nvim_create_augroup('VindentSigns', { clear = true })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          group = augroup_id,
          callback = on_cursor_moved,
        })

        vim.api.nvim_create_autocmd('BufEnter', {
          group = augroup_id,
          callback = on_buf_enter,
        })

        vim.api.nvim_create_autocmd('BufLeave', {
          group = augroup_id,
          callback = on_buf_leave,
        })

        dirty = true
        redraw()
      end

      function M.hide()
        if not visible then
          return
        end
        visible = false

        clear_all()

        if augroup_id then
          pcall(vim.api.nvim_del_augroup_by_id, augroup_id)
          augroup_id = nil
        end
      end

      function M.toggle()
        if visible then
          M.hide()
        else
          M.show()
        end
        return visible
      end

      -- Toggle-only command (no args)
      vim.api.nvim_create_user_command('VindentSigns', function()
        local state = M.toggle()
        vim.notify('Vindent signs ' .. (state and 'enabled' or 'disabled'), vim.log.levels.INFO)
      end, { desc = 'Toggle vindent signs in gutter' })

      -- Start based on opts.enabled (default OFF per opts above)
      if DEFAULT_ENABLED then
        M.show()
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
