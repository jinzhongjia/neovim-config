-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- DiffTool — Neovim 0.12 built-in directory/file diff
-- No plugin needed, just :packadd
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Load the built-in difftool plugin
vim.cmd.packadd("nvim.difftool")

-- Keymaps for DiffTool
local map = vim.keymap.set

-- Diff two files or directories interactively
map("n", "<leader>gd", function()
  local left = vim.fn.input("Left (file/dir): ", "", "file")
  if left == "" then return end
  local right = vim.fn.input("Right (file/dir): ", "", "file")
  if right == "" then return end
  vim.cmd("DiffTool " .. vim.fn.fnameescape(left) .. " " .. vim.fn.fnameescape(right))
end, { desc = "DiffTool: Compare files/dirs" })

-- Quick diff: current file vs git HEAD
map("n", "<leader>gD", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end
  -- Use git show to get HEAD version, write to temp
  local obj = vim.system({ "git", "show", "HEAD:" .. vim.fn.fnamemodify(file, ":.") }, { text = true }):wait()
  if obj.code ~= 0 then
    vim.notify("Not a git-tracked file or not in a git repo", vim.log.levels.WARN)
    return
  end
  local tmp = vim.fn.tempname()
  local f = io.open(tmp, "w")
  if f then
    f:write(obj.stdout)
    f:close()
  end
  require("nvim.difftool").open(tmp, file, {
    rename = { detect = true, similarity = 0.5 },
  })
end, { desc = "DiffTool: Current file vs HEAD" })

-- Git difftool integration (for use as external difftool)
-- Add to your .gitconfig:
--   [difftool "nvim"]
--     cmd = nvim -c "packadd nvim.difftool" -c "DiffTool $LOCAL $REMOTE"
--   [diff]
--     tool = nvim
