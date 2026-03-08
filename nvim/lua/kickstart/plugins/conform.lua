return {
  'stevearc/conform.nvim',
  version = 'v9.*',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  lazy = true,
  dependencies = {
    'j-hui/fidget.nvim',
  },
  keys = function()
    local function prompt_and_format(range)
      -- Get available formatters for current filetype
      local conform = require 'conform'
      local formatters = conform.list_formatters_for_buffer()

      if #formatters == 0 then
        vim.notify('No formatters available for this filetype', vim.log.levels.WARN)
        return
      end

      -- formatters is already a list of formatter names (strings)
      vim.ui.select(formatters, {
        prompt = string.format('Format %s with:', vim.bo.filetype),
      }, function(choice)
        if not choice then
          return
        end

        -- Create fidget progress handle
        local progress = require 'fidget.progress'
        local handle = progress.handle.create {
          title = 'Formatting',
          message = choice,
          lsp_client = { name = 'conform' },
        }

        -- Track start time
        local start_time = vim.loop.hrtime()

        conform.format({
          formatters = { choice },
          range = range,
          quiet = true,
        }, function(err)
          local elapsed_ms = (vim.loop.hrtime() - start_time) / 1000000

          if err then
            handle:cancel()
            vim.notify(string.format('[Conform] %s failed in %.0fms\n%s', choice, elapsed_ms, err), vim.log.levels.ERROR)
          else
            handle:report {
              message = string.format('%s completed in %.0fms', choice, elapsed_ms),
            }
            vim.defer_fn(function()
              handle:finish()
            end, 500)
          end
        end)
      end)
    end

    return {
      {
        '<leader>cf',
        function()
          prompt_and_format(nil) -- whole buffer
        end,
        mode = 'n',
        desc = 'Select Code [f]ormatter for buffer',
      },
      {
        '<leader>cf',
        function()
          local start_line = vim.fn.line 'v'
          local end_line = vim.fn.line '.'
          if start_line > end_line then
            start_line, end_line = end_line, start_line
          end
          prompt_and_format {
            start = { start_line, 0 },
            ['end'] = { end_line, 0 },
          }
        end,
        mode = 'x',
        desc = 'Select Code [f]ormatter for selection',
      },
    }
  end,
  opts = {
    notify_on_error = false,
    log_level = vim.log.levels.TRACE,
    default_format_opts = {
      timeout_ms = 10000,
    },
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = {
        c = true,
        cpp = true,
        python = true,
        sql = true,
      }

      -- Get buffer file path and expand home directory
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local expanded_path = vim.fn.expand(bufname)

      -- Disable formatting for specific files
      if expanded_path:match '.config/bottom/bottom%.toml$' then
        return nil
      end

      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff-fix', 'black' }, -- ruff fix linting issues, then black format
      html = { 'prettierd' },
      markdown = { 'prettierd' },
      ini = { 'prettierd' },
      yaml = { 'prettierd' },
      helm = {}, -- Disable formatting for Helm template files
      json = { 'prettierd' },
      xml = { 'xmllint' },
      toml = { 'taplo' },
      sh = { 'shfmt' },
      dockerfile = { 'dockerfmt' },
      sql = { 'sqlfluff-postgres', 'sqlfluff-mysql', 'sqlfluff-sqlite' },
    },
    formatters = {
      ['ruff-fix'] = {
        command = 'ruff',
        args = { 'check', '--select', 'F401', 'Q', 'I', '--fix', '$FILENAME' },
        stdin = false,
      },
      ['sqlfluff-postgres'] = {
        command = 'sqlfluff',
        args = { 'fix', '--dialect', 'postgres', '$FILENAME' },
        stdin = false,
        exit_codes = { 0, 1 }, -- exit code 1 = unfixable violations (still applies fixes)
      },
      ['sqlfluff-mysql'] = {
        command = 'sqlfluff',
        args = { 'fix', '--dialect', 'mysql', '$FILENAME' },
        stdin = false,
        exit_codes = { 0, 1 }, -- exit code 1 = unfixable violations (still applies fixes)
      },
      ['sqlfluff-sqlite'] = {
        command = 'sqlfluff',
        args = { 'fix', '--dialect', 'sqlite', '$FILENAME' },
        stdin = false,
        exit_codes = { 0, 1 }, -- exit code 1 = unfixable violations (still applies fixes)
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
