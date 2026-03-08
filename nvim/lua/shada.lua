-- [[ Per-project shada file ]]
--
-- Stores shada (marks, history, etc.) separately for each git project.
-- Falls back to 'global' for non-git directories.

local function find_git_root()
  local git_dir = vim.fn.finddir('.git', '.;')
  if git_dir == '' then
    return nil
  end
  return vim.fn.fnamemodify(git_dir, ':h:p')
end

-- Project ID: basename + 7-char SHA256 hash of full path
local function make_project_id()
  local root = find_git_root()
  if not root then
    return 'global'
  end
  local name = vim.fn.fnamemodify(root, ':t')
  local hash = vim.fn.sha256(root):sub(1, 7)
  return name .. '_' .. hash
end

local project_id = make_project_id()
local data_dir = vim.fn.stdpath 'state' .. '/shada/' .. project_id
local shada_file = data_dir .. '/main.shada'

if vim.fn.isdirectory(data_dir) == 0 then
  vim.fn.mkdir(data_dir, 'p')
end

vim.opt.shadafile = shada_file

-- vim: ts=2 sts=2 sw=2 et
