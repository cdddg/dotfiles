# nvim

Personal Neovim configuration.

## Origin

Forked from [cdddg/kickstart-modular.nvim@`9125b8f`](https://github.com/cdddg/kickstart-modular.nvim/tree/9125b8ff745849b928cf6330a8d5f26a224d4450) (2026-02-13, branch: `fork`)

Upstream chain:
- [dam9000/kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim)
- [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

## Structure

```
lua/
├── kickstart/          -- upstream plugins (from kickstart-modular.nvim)
│   ├── health.lua
│   └── plugins/
├── supplement/         -- personal additions
│   ├── colorscheme.lua
│   ├── commands/       -- custom commands (loaded via require in init.lua)
│   └── plugins/        -- additional plugins
├── options.lua
├── keymaps.lua
├── shada.lua           -- per-project shada files
├── lazy-bootstrap.lua
└── lazy-plugins.lua
```
