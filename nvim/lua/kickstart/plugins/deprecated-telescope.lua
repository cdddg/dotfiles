-- NOTE: Plugins can specify dependencies.
--
-- The dependencies are proper plugin specifications as well - anything
-- you do for a plugin at the top level, you can do for a dependency.
--
-- Use the `dependencies` key to specify the dependencies of a particular plugin

return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  version = '0.2.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    { 'fdschmidt93/telescope-egrepify.nvim' },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Custom Highlight for Marks ]]
    local function setup_marks_highlight()
      local num_hl = vim.api.nvim_get_hl(0, { name = 'Number', link = false })
      vim.api.nvim_set_hl(0, 'TelescopeMarksAlpha', { fg = num_hl.fg, bold = true })

      -- 讓 TelescopeSelection 只設背景色，保留各 entry 的前景色
      local sel_hl = vim.api.nvim_get_hl(0, { name = 'TelescopeSelection', link = false })
      vim.api.nvim_set_hl(0, 'TelescopeSelection', { bg = sel_hl.bg, bold = sel_hl.bold })
    end
    setup_marks_highlight()
    -- 當 colorscheme 改變時重新設定
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = setup_marks_highlight,
    })

    -- [[ Custom Action ]]
    local function select_all_results(picker)
      local row = 1
      for _ in picker.manager:iter() do
        picker:add_selection(picker:get_row(row))
        row = row + 1
      end
    end

    local function open_multiple_selected(prompt_bufnr)
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      local function open_file(entry)
        local filename = entry.filename or entry.value
        local lnum = entry.lnum or 1
        local lcol = entry.col or 1
        if not filename then
          return
        end

        local abs_filename = vim.fn.fnamemodify(filename, ':p')
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == abs_filename then
            vim.api.nvim_set_current_buf(buf)
            vim.cmd(string.format('normal! %dG%d|', lnum, lcol))
            return
          end
        end

        vim.cmd(string.format('tabnew +%d %s', lnum, filename))
        vim.cmd(string.format('normal! %dG%d|', lnum, lcol))
      end

      local picker = action_state.get_current_picker(prompt_bufnr)
      local multi = picker:get_multi_selection()

      if vim.tbl_isempty(multi) then
        actions.select_default(prompt_bufnr)
      else
        actions.close(prompt_bufnr)
        for _, entry in pairs(multi) do
          open_file(entry)
        end
      end
    end

    local function is_neotree_buffer()
      return vim.bo.filetype == 'neo-tree'
    end

    local function safe_telescope_search(search_fn)
      return function()
        if is_neotree_buffer() then
          vim.notify('Search is disabled in Neo-tree buffer', vim.log.levels.ERROR)
        else
          search_fn()
        end
      end
    end

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      defaults = {
        mappings = {
          i = {
            ['<C-Enter>'] = 'to_fuzzy_refine',
            ['<C-p>'] = require('telescope.actions').cycle_history_prev,
            ['<C-n>'] = require('telescope.actions').cycle_history_next,
            ['<C-o>'] = open_multiple_selected, -- Bind the custom action to <C-o>
            ['<C-a>'] = function(prompt_bufnr)
              local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
              select_all_results(picker)
            end,
          },
          n = {
            ['q'] = require('telescope.actions').close,
            ['<C-o>'] = open_multiple_selected, -- Bind the custom action to <C-o>
            ['<C-a>'] = function(prompt_bufnr)
              local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
              select_all_results(picker)
            end,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
        },
        grep_string = {
          additional_args = {
            '--hidden',
          },
        },
        live_grep = {
          file_ignore_patterns = { '^%.git/', '^node_modules/', '^%.venv/' },
          additional_args = {
            '--hidden',
          },
        },
        marks = {
          entry_maker = function(entry)
            local displayer = require('telescope.pickers.entry_display').create {
              separator = ' ',
              items = {
                { width = 2 },
                { width = 6 },
                { width = 4 },
                { remaining = true },
              },
            }

            -- entry.line 格式: "mark   lnum  col name"
            local mark = entry.line:match '^(%S+)'
            local hl_group = nil
            if mark and mark:match '^[a-zA-Z]$' then
              hl_group = 'TelescopeMarksAlpha'
            end

            return {
              value = entry,
              ordinal = entry.line,
              display = function()
                return displayer {
                  { mark or '?', hl_group },
                  { entry.lnum, 'TelescopeResultsLineNr' },
                  { entry.col, 'TelescopeResultsLineNr' },
                  entry.filename and vim.fn.fnamemodify(entry.filename, ':~:.') or '',
                }
              end,
              lnum = entry.lnum,
              col = entry.col,
              filename = entry.filename,
            }
          end,
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
        ['egrepify'] = {
          filename_hl = 'Special',
          results_ts_hl = false,
          prefixes = {
            -- ! 反向匹配：搜尋不包含指定內容的行; 範例：! sorter → 找出所有不含 "sorter" 的行
            ['!'] = {
              flag = 'invert-match',
            },
            -- - 區分大小寫：精確匹配大小寫; 範例：-Telescope → 只找 "Telescope"，不找 "telescope"
            ['-'] = {
              flag = 'case-sensitive',
            },
            -- = 字面搜尋：不使用正則表達式，搜尋原始字串; 範例：=function.* → 搜尋 "function.*" 這個字面文字
            ['='] = {
              flag = 'fixed-strings',
            },
          },
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
    pcall(require('telescope').load_extension, 'egrepify')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search [f]iles' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search [d]iagnostics' })
    vim.keymap.set('n', '<leader>s<space>r', builtin.resume, { desc = 'Search [r]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Search Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>sm', builtin.marks, { desc = 'Search [m]arks' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        prompt_title = 'Live [g]rep in Open Files',
        grep_open_files = true,
      }
    end, { desc = 'Search [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>s<space>n', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = 'Search [n]eovim files' })

    -- Additional
    vim.keymap.set(
      'n',
      '<leader>sg',
      safe_telescope_search(function()
        require('telescope.builtin').live_grep()
      end),
      { desc = 'Search by [g]rep regex' }
    )
    vim.keymap.set(
      'n',
      '<leader>sl',
      safe_telescope_search(function()
        require('telescope.builtin').live_grep {
          prompt_title = 'Literal Search',
          additional_args = function()
            return { '--fixed-strings', '--hidden' }
          end,
        }
      end),
      { desc = 'Search by [l]iteral grep without regex' }
    )
    vim.keymap.set(
      'n',
      '<leader>sa',
      safe_telescope_search(function()
        require('telescope').extensions.egrepify.egrepify {
          prompt_title = 'Advanced Live Grep',
        }
      end),
      { desc = 'Search [a]dvanced grep' }
    )

    -- Jumplist with vertical layout
    vim.keymap.set('n', '<leader>sj', function()
      builtin.jumplist {
        layout_strategy = 'vertical',
        layout_config = {
          preview_height = 0.5,
          height = 0.8,
          prompt_position = 'bottom',
        },
        results_height = 10,
        show_line = true,
      }
    end, { desc = 'Search [j]umplist' })

    -- Add the autocmd to show line numbers in Telescope previewer
    vim.cmd [[
        autocmd User TelescopePreviewerLoaded setlocal number
      ]]
  end,
}
-- vim: ts=2 sts=2 sw=2 et
