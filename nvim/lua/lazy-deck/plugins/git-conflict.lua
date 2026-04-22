return {
  'akinsho/git-conflict.nvim',
  version = '*',
  opts = {
    disable_diagnostics = true,
    default_mappings = false,
  },
  config = function(_, opts)
    -- Nvim 0.12 removed vim.diagnostic.disable and the old enable(bufnr) signature.
    -- git-conflict.nvim still calls both, so shim them to the new enable(enabled, filter) API.
    if not vim.diagnostic.disable then
      vim.diagnostic.disable = function(bufnr)
        vim.diagnostic.enable(false, { bufnr = bufnr })
      end
      local original_enable = vim.diagnostic.enable
      vim.diagnostic.enable = function(a, b)
        if type(a) == 'number' then
          return original_enable(true, { bufnr = a })
        end
        return original_enable(a, b)
      end
    end
    -- Wrap git-conflict's decoration provider to skip windows inside diffview
    -- tabs, avoiding "Invalid 'line': out of range" when diffview shows a
    -- conflict file whose line count diverges from the cached positions.
    local gc_ns = vim.api.nvim_create_namespace('git-conflict')

    -- git-conflict 把 label 文字寫死成 "(Current/Incoming/Base changes)"，沒有 config 可調，
    -- 所以攔截它畫 label 的 extmark，把括弧內容換成真實 branch / stash 名。
    -- ponytail: monkeypatch 是唯一不 fork 的路；要更簡單就拿掉這段、忍受預設文字。
    local function git(dir, ...)
      local out = vim.fn.system(vim.list_extend({ 'git', '-C', dir }, { ... }))
      if vim.v.shell_error ~= 0 then return nil end
      out = vim.trim(out)
      return out ~= '' and out or nil
    end
    local function read1(path)
      local f = io.open(path, 'r'); if not f then return nil end
      local l = f:read('*l'); f:close(); return l
    end
    local function resolve_names(buf)
      local file = vim.api.nvim_buf_get_name(buf)
      if file == '' then return {} end
      local dir = vim.fs.dirname(file)
      local gitdir = git(dir, 'rev-parse', '--absolute-git-dir')
      local ours = git(dir, 'symbolic-ref', '--short', 'HEAD')
        or git(dir, 'rev-parse', '--short', 'HEAD') or 'HEAD'
      local theirs = 'stash/patch' -- 無 MERGE_HEAD：stash pop 或 git apply --3way 都會走這，分不出
      if gitdir then
        if vim.uv.fs_stat(gitdir .. '/MERGE_HEAD') then
          local msg = read1(gitdir .. '/MERGE_MSG') or ''
          theirs = msg:match("Merge branch '([^']+)'")
            or msg:match("Merge remote%-tracking branch '([^']+)'")
            or git(dir, 'rev-parse', '--short', 'MERGE_HEAD') or 'merge'
        elseif vim.uv.fs_stat(gitdir .. '/CHERRY_PICK_HEAD') then
          theirs = 'cherry-pick'
        elseif vim.uv.fs_stat(gitdir .. '/rebase-merge') or vim.uv.fs_stat(gitdir .. '/rebase-apply') then
          local hn = read1(gitdir .. '/rebase-merge/head-name')
          theirs = hn and hn:gsub('^refs/heads/', '') or 'rebase'
        end
      end
      return { ours = ours, theirs = theirs, base = 'base' }
    end
    local function rewrite(o, buf)
      local names = vim.b[buf].gc_names
      if not names then names = resolve_names(buf); vim.b[buf].gc_names = names end
      for _, chunk in ipairs(o.virt_text) do
        local txt = vim.trim(chunk[1])
        local repl
        -- 按鍵 + 角色字 + 真實名稱，直接看括弧就知道按誰。
        if txt:find('(Current changes)', 1, true) then repl = 'Current Change: ' .. names.ours .. ' [co]'
        elseif txt:find('(Incoming changes)', 1, true) then repl = 'Incoming Change: ' .. names.theirs .. ' [ct]'
        elseif txt:find('(Base changes)', 1, true) then repl = 'Base: ' .. names.base end
        if repl then
          local core = txt:gsub('%([^()]*changes%)%s*$', '(' .. repl .. ')')
          local pad = vim.api.nvim_win_get_width(0) - vim.api.nvim_strwidth(core)
          if pad > 0 then core = core .. string.rep(' ', pad) end
          chunk[1] = core
        end
      end
    end

    local orig_set_provider = vim.api.nvim_set_decoration_provider
    vim.api.nvim_set_decoration_provider = function(ns, handlers)
      if ns == gc_ns and handlers and handlers.on_win then
        local orig_on_win = handlers.on_win
        local orig_on_buf = handlers.on_buf
        handlers = {
          on_buf = function(_, bufnr, tick)
            if orig_on_buf then return orig_on_buf(_, bufnr, tick) end
          end,
          on_win = function(_, winid, bufnr, topline, botline)
            local ok, flagged = pcall(function()
              return vim.t[vim.api.nvim_win_get_tabpage(winid)].diffview_view_initialized
            end)
            if ok and flagged then return false end
            -- 暫時換掉 set_extmark 來改寫 label，draw 結束立刻還原。
            local orig_extmark = vim.api.nvim_buf_set_extmark
            vim.api.nvim_buf_set_extmark = function(b, ens, line, col, eo)
              if ens == gc_ns and eo and eo.virt_text then pcall(rewrite, eo, b) end
              return orig_extmark(b, ens, line, col, eo)
            end
            local ok2, res = pcall(orig_on_win, _, winid, bufnr, topline, botline)
            vim.api.nvim_buf_set_extmark = orig_extmark
            if not ok2 then error(res) end
            return res
          end,
        }
      end
      return orig_set_provider(ns, handlers)
    end
    require('git-conflict').setup(opts)
    vim.api.nvim_set_decoration_provider = orig_set_provider

    -- 衝突 buffer 才掛 keymap，並帶 desc 讓 which-key 顯示用途。
    -- ours = 上半 (<<<<<<< HEAD / Updated upstream)
    -- theirs = 下半 (>>>>>>> branch / Stashed changes)
    -- rebase 期間 ours/theirs 與直覺相反：HEAD 是 upstream，incoming 才是你的 commit
    local conflict_maps = {
      { 'co', '<Plug>(git-conflict-ours)',          'Conflict: ours 上半 (HEAD / Updated upstream)' },
      { 'ct', '<Plug>(git-conflict-theirs)',        'Conflict: theirs 下半 (incoming / Stashed changes)' },
      { 'cb', '<Plug>(git-conflict-both)',          'Conflict: both 兩邊都保留' },
      { 'c0', '<Plug>(git-conflict-none)',          'Conflict: none 兩邊都丟掉' },
      { ']x', '<Plug>(git-conflict-next-conflict)', 'Conflict: 下一個衝突' },
      { '[x', '<Plug>(git-conflict-prev-conflict)', 'Conflict: 上一個衝突' },
    }
    vim.api.nvim_create_autocmd('User', {
      pattern = 'GitConflictDetected',
      callback = function(args)
        for _, m in ipairs(conflict_maps) do
          vim.keymap.set('n', m[1], m[2], { buffer = args.buf, silent = true, desc = m[3] })
        end
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'GitConflictResolved',
      callback = function(args)
        vim.b[args.buf].gc_names = nil
        for _, m in ipairs(conflict_maps) do
          pcall(vim.keymap.del, 'n', m[1], { buffer = args.buf })
        end
      end,
    })
  end,
}
-- vim: ts=2 sts=2 sw=2 et
