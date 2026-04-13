-- Forked from cdddg/kickstart-modular.nvim@9125b8f (2026-02-13)

-- Leader (must be set before plugins load)
vim.g.mapleader = '\\'
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require 'options'
require 'keymaps'
require 'terminal'
require 'shada'
require 'commands'
require 'lazy-bootstrap'
require 'lazy-plugins'

-- vim: ts=2 sts=2 sw=2 et
