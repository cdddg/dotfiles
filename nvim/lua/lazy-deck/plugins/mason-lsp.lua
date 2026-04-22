-- LSP Configuration (Neovim 0.12 native API)
--
-- Server definitions are in nvim/lsp/*.lua (one file per server).
-- Mason handles installation; vim.lsp.enable() activates servers natively.

-- lsp/*.lua filename → mason package name (only for names that differ)
local mason_package_map = {
  bashls = 'bash-language-server',
  copilot = 'copilot-language-server',
  docker_compose_language_service = 'docker-compose-language-service',
  dockerls = 'dockerfile-language-server',
  helm_ls = 'helm-ls',
  jsonls = 'json-lsp',
  lua_ls = 'lua-language-server',
  nginx_language_server = 'nginx-language-server',
  yamlls = 'yaml-language-server',
}

return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    version = 'v1.*',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Mason: auto-install LSPs and tools
    'mason-org/mason.nvim',
    version = 'v2.*',
    dependencies = {
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = {
            display = {
              progress_icon = { pattern = 'dots_pulse', period = 0.6 },
            },
          },
        },
      },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',

      -- UI and enhanced LSP UIs (including rename)
      {
        'glepnir/lspsaga.nvim',
        event = 'LspAttach',
        branch = 'main',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
          require('lspsaga').setup {
            lightbulb = {
              enable = false,
            },
            outline = {
              layout = 'normal',
              win_position = 'left',
              win_width = 35,
              auto_preview = false,
              detail = true,
              auto_refresh = true,
              close_after_jump = false,
              cursorline = true,
            },
            finder = {
              layout = 'float',
            },
            rename = {
              in_select = false,
              keys = {
                quit = 'q',
              },
            },
          }
          vim.api.nvim_set_hl(0, 'SagaBeacon', { link = 'IncSearch' })
        end,
      },
    },
    config = function()
      require('mason').setup()

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        virtual_text = {
          source = false,
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          source = true,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '✖',
            [vim.diagnostic.severity.WARN] = '󱈸',
            [vim.diagnostic.severity.INFO] = 'ℹ',
            [vim.diagnostic.severity.HINT] = '⚑',
          },
        },
      }
      require('diagnostics').apply_persisted()

      -- Broadcast blink.cmp capabilities to all LSP servers
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      -- Discover LSP servers from nvim/lsp/*.lua
      local lsp_servers = {}
      local ensure_installed = { 'stylua' }
      for _, f in ipairs(vim.fn.readdir(vim.fn.stdpath 'config' .. '/lsp')) do
        if f:match '%.lua$' then
          local name = f:gsub('%.lua$', '')
          table.insert(lsp_servers, name)
          table.insert(ensure_installed, mason_package_map[name] or name)
        end
      end

      -- Ensure servers and tools are installed via Mason (uses mason package names)
      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
      }

      -- Enable all LSP servers (configs loaded from nvim/lsp/*.lua)
      vim.lsp.enable(lsp_servers)

      --  This function gets run when an LSP attaches to a particular buffer.
      --    Every time a new file is opened that is associated with an lsp
      --    (for example, opening `main.rs` is associated with `rust_analyzer`)
      --    this function will be executed to configure the current buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach-group', { clear = true }),
        callback = function(event)
          -- Disable ty's language service capabilities so only diagnostics remain.
          -- This prevents duplicate results (e.g. gd showing two entries) when pyright is also active.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == 'ty' then
            local caps = client.server_capabilities
            caps.definitionProvider = false
            caps.referencesProvider = false
            caps.hoverProvider = false
            caps.completionProvider = nil
            caps.renameProvider = false
            caps.signatureHelpProvider = nil
            caps.documentFormattingProvider = false
          end

          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Override Neovim 0.11+ built-in gr* mappings with lspsaga / fzf-lua
          map('grr', '<cmd>Lspsaga finder ref<CR>', 'goto [r]eferences')
          map('grn', '<cmd>Lspsaga rename<CR>', 're[n]ame')
          map('gra', vim.lsp.buf.code_action, 'code [a]ction', { 'n', 'x' })
          map('gri', '<cmd>FzfLua lsp_implementations<CR>', 'goto [i]mplementation')
          map('grt', '<cmd>FzfLua lsp_typedefs<CR>', 'goto [t]ype definition')
          map('grx', vim.lsp.codelens.run, 'codelens run')
          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', vim.lsp.buf.definition, 'Go to [d]efinition')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, 'Go to [D]eclaration')

          -- Additional; you can use the following mappings to navigate
          map('gs', vim.lsp.buf.signature_help, 'Signature Help')

          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            return client:supports_method(method, bufnr)
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight-group', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach-group', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight-group', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
