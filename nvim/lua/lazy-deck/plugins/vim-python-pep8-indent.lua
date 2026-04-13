return {
  'Vimjas/vim-python-pep8-indent',
  ft = 'python',
  init = function()
    -- 關閉 Neovim 內建的 PEP8 style（預設 1：啟用核心 ftplugin/python.vim 的縮排設定）
    vim.g.python_recommended_style = 0

    -- 多行字符串初始縮排（預設 0：新/空行不額外縮排）
    --   -1：保留 Vim 的 autoindent（現有縮排）
    --   -2：用於 textwrap.dedent 等場景，在起始空行後增加一層縮排
    vim.g.python_pep8_indent_multiline_string = 0

    -- 控制閉括號的縮排行為（預設 0：與開括號所在行對齊；1：與內部元素對齊）
    vim.g.python_pep8_indent_hang_closing = 0
  end,
}
-- vim: ts=2 sts=2 sw=2 et
