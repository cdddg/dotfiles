local dir = vim.fn.stdpath 'config' .. '/lua/commands'
for _, file in ipairs(vim.fn.readdir(dir)) do
  if file ~= 'init.lua' and file:match '%.lua$' then
    require('commands.' .. file:gsub('%.lua$', ''))
  end
end

-- :tabs → custom tab selector
vim.cmd [[cnoreabbrev <expr> tabs getcmdtype()==':'&&getcmdline()=='tabs'?'Tabs':'tabs']]

-- vim: ts=2 sts=2 sw=2 et
