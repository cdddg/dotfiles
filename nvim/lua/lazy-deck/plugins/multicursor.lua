return {
  'jake-stewart/multicursor.nvim',
  branch = '1.0',
  event = 'VeryLazy',
  lazy = true,
  config = function()
    local mc = require 'multicursor-nvim'
    mc.setup()

    local set = vim.keymap.set
    -- Add and remove cursors with control + left click.
    set('n', '<c-leftmouse>', mc.handleMouse)
    set('n', '<c-leftdrag>', mc.handleMouseDrag)
    set('n', '<c-leftrelease>', mc.handleMouseRelease)

    -- Disable and enable cursors.
    set({ 'n', 'x' }, 'M', mc.toggleCursor)

    -- Mappings defined in a keymap layer only apply when there are
    -- multiple cursors. This lets you have overlapping mappings.
    mc.addKeymapLayer(function(layerSet)
      -- Select a different cursor as the main one.
      layerSet({ 'n', 'x' }, '<left>', mc.prevCursor)
      layerSet({ 'n', 'x' }, '<right>', mc.nextCursor)

      -- -- Allow insert/append commands (i, I, a, A) only when MultiCursor mode is active; disable them in MS-Select mode.
      -- local function multi_insert_key(key)
      --   if mc.cursorsEnabled() then
      --     local term = vim.api.nvim_replace_termcodes(key, true, false, true)
      --     vim.api.nvim_feedkeys(term, 'n', false)
      --   end
      -- end
      -- -- stylua: ignore start
      -- layerSet('n', 'i', function() multi_insert_key 'i' end)
      -- layerSet('n', 'a', function() multi_insert_key 'a' end)
      -- layerSet('n', 'I', function() multi_insert_key 'I' end)
      -- layerSet('n', 'A', function() multi_insert_key 'A' end)
      -- stylua: ignore end

      -- Enable and clear cursors using escape.
      layerSet('n', '<esc>', function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
        -- stylua: ignore
        vim.schedule(function() vim.cmd 'redrawstatus' end)
      end)
    end)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, 'MultiCursorCursor', { reverse = true })
    hl(0, 'MultiCursorVisual', { link = 'Visual' })
    hl(0, 'MultiCursorSign', { link = 'SignColumn' })
    hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
    hl(0, 'MultiCursorDisabledCursor', { reverse = true })
    hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
    hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
  end,
}
-- vim: ts=2 sts=2 sw=2 et
