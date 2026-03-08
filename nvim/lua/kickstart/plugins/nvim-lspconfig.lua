-- **什麼是 LSP？**
--
-- LSP 是你可能聽過但不太理解的縮寫。
--
-- LSP 代表 Language Server Protocol（語言伺服器協定）。
-- 它是一種讓編輯器和語言工具以標準化方式溝通的協定。
--
-- 一般來說，有一個「伺服器」是用來理解特定語言的工具
-- （如 `gopls`、`lua_ls`、`rust_analyzer` 等）。這些語言伺服器
-- 是獨立的程序，與「客戶端」溝通——在這裡就是 Neovim！
--
-- LSP 為 Neovim 提供以下功能：
--  - 跳轉到定義
--  - 查找引用
--  - 自動補全
--  - 符號搜尋
--  - 等等！
--
-- 因此，語言伺服器是必須與 Neovim 分開安裝的外部工具。
-- 這就是 `mason` 和相關插件發揮作用的地方。
--
-- 如果你想了解 LSP 和 Treesitter 的差異，
-- 可以查看 `:help lsp-vs-treesitter`

return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    version = '*',
    dependencies = {
      -- Mason: auto-install LSPs and tools (must load before dependents)
      {
        'mason-org/mason.nvim',
        version = 'v2.*',
        opts = {},
      },

      {
        'mason-org/mason-lspconfig.nvim',
        version = 'v2.*',
      },

      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = {
            display = {
              progress_icon = { pattern = 'dots_pulse', period = 0.6 }, -- dots, dots_negative, dots_snake, dots_footsteps, line, pipe, dots_ellipsis, box
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
              layout = 'normal', -- 'normal' for sidebar, 'float' for floating window
              win_position = 'left', -- 'left' or 'right'
              win_width = 35, -- sidebar width
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
    init = function()
      local function lspconfig_is_tag(tag_name)
        local plugin = require('lazy.core.config').plugins['nvim-lspconfig']
        if not plugin or not plugin.dir then
          return false
        end

        local lspconfig_path = plugin.dir
        local cmd = string.format("git -C '%s' describe --tags --exact-match 2>/dev/null", lspconfig_path)
        local handle = io.popen(cmd)
        if not handle then
          return false
        end

        local tag = handle:read('*a'):gsub('%s+', '')
        handle:close()
        return tag == tag_name
      end

      local function set_lsp_util_default_encoding(method_name, default_encoding)
        local util = vim.lsp.util
        local orig = util[method_name]
        util[method_name] = function(arg1, encoding)
          return orig(arg1, encoding or default_encoding)
        end
      end

      -- https://github.com/neovim/nvim-lspconfig/releases
      if lspconfig_is_tag 'v2.5.0' then
        set_lsp_util_default_encoding('make_position_params', 'utf-8')
        set_lsp_util_default_encoding('make_range_params', 'utf-8')
      end
    end,
    config = function()
      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      -- For Neovim version 0.10 and above
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
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- Python Language Server - linting, type checking, and more
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'standard',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        ruff = {
          capabilities = {
            offsetEncoding = 'utf-16',
          },
        },
        ty = {
          settings = {
            ty = {
              disableLanguageServices = true,
            },
          },
        },

        -- Bash Language Server - shell script completion and validation
        bashls = {},

        -- TOML Language Server - validation and formatting
        taplo = {},

        -- JSON Language Server - schema validation and completion
        jsonls = {},

        -- Dockerfile Language Server - syntax validation and completion
        dockerls = {},

        -- Docker Compose Language Service
        docker_compose_language_service = {
          -- Provides validation and completion for docker-compose.yml files
          filetypes = { 'docker-compose' },
        },

        -- Helm Language Server - chart template completion and validation
        helm_ls = {
          filetypes = { 'helm' },
        },

        yamlls = {
          -- YAML Language Server with schema support
          settings = {
            yaml = {
              schemas = {
                -- Kubernetes schemas
                ['https://json.schemastore.org/kustomization.json'] = 'kustomization.{yml,yaml}',
                ['https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json'] = '*.k8s.{yml,yaml}',
                -- GitHub Actions
                ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*.{yml,yaml}',
                -- Docker Compose
                ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = 'docker-compose*.{yml,yaml}',
              },
              format = {
                enable = true,
              },
              validate = true,
              completion = true,
            },
          },
        }, -- YAML Language Server - schema support for K8s, GitHub Actions, etc.

        -- NGINX Language Server
        nginx_language_server = {
          -- Provides completion and validation for nginx configuration files
        },

        -- Lua Language Server - completion, diagnostics, and type checking
        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        -- Markdown Language Server - completion and navigation
        marksman = {},

        -- GitHub Copilot - AI-powered code suggestions
        copilot = {},
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_enable = true,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      --  This function gets run when an LSP attaches to a particular buffer.
      --    Every time a new file is opened that is associated with an lsp
      --    (for example, opening `main.rs` is associated with `rust_analyzer`)
      --    this function will be executed to configure the current buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
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

          -- Rename using lspsaga UI instead of built-in
          --  Most Language Servers support renaming across files, etc.
          map('<leader>cr', '<cmd>Lspsaga rename<CR>', '[r]ename', { 'n', 'x' })

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, 'goto Code [a]ction', { 'n', 'x' })

          -- Find references for the word under your cursor.
          map('gr', '<cmd>Lspsaga finder def+ref+imp<CR>', 'Goto [r]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, 'Goto [I]mplementation')
          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, 'Go to [d]efinition')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, 'Go to [D]eclaration')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          -- map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

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
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
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
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
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

      -- List all active LSP clients
      vim.api.nvim_create_user_command('LspList', function()
        local clients = vim.lsp.get_clients()
        if #clients == 0 then
          print 'No LSP clients are currently active'
          return
        end

        print 'Active LSP clients:'
        for _, client in ipairs(clients) do
          local buf_count = #vim.lsp.get_buffers_by_client_id(client.id)
          print(string.format('  • %s (attached to %d buffer%s)', client.name, buf_count, buf_count ~= 1 and 's' or ''))
        end
      end, { desc = 'List all active LSP servers' })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
