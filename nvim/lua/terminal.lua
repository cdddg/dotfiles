-- Terminal-specific keymaps and autocmds

if vim.env.GHOSTTY_RESOURCES_DIR then
  -- Cmd+S / Cmd+Shift+S → save (Ghostty forwards these as <C-s> / <C-S-s>)
  vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<Esc><cmd>w<CR>', { desc = 'Save file' })
  vim.keymap.set({ 'n', 'i', 'v' }, '<C-S-s>', '<Esc><cmd>wa<CR>', { desc = 'Save all files' })

  -- Window navigation: <C-hjkl> → <C-w>hjkl
  vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
  vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
  vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

  -- Edge-aware window resize: <M-w>hjkl
  -- Flips +/- when at the last (rightmost/bottom) window, similar to smart-splits
  local function smart_resize(dir, amount)
    amount = amount or 4
    if dir == 'left' or dir == 'right' then
      local at_last = vim.fn.winnr() == vim.fn.winnr 'l'
      local sign = ((dir == 'right') ~= at_last) and '+' or '-'
      vim.cmd('vertical resize ' .. sign .. amount)
    else
      local at_last = vim.fn.winnr() == vim.fn.winnr 'j'
      local sign = ((dir == 'down') ~= at_last) and '+' or '-'
      vim.cmd('resize ' .. sign .. amount)
    end
  end

  -- stylua: ignore start
  vim.keymap.set('n', '<M-h>', function() smart_resize 'left' end, { desc = 'Resize window left' })
  vim.keymap.set('n', '<M-j>', function() smart_resize 'down' end, { desc = 'Resize window down' })
  vim.keymap.set('n', '<M-k>', function() smart_resize 'up' end, { desc = 'Resize window up' })
  vim.keymap.set('n', '<M-l>', function() smart_resize 'right' end, { desc = 'Resize window right' })
  -- stylua: ignore end
end

-- vim: ts=2 sts=2 sw=2 et
