-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- DiffTool — Neovim 0.12 built-in directory/file diff
-- No plugin needed, just :packadd
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Load the built-in difftool plugin
vim.cmd.packadd("nvim.difftool")

-- Keymaps for DiffTool
local map = vim.keymap.set

-- 任意两个文件/目录比较直接用 :DiffTool <left> <right>（自带路径补全），
-- 不占键位；<leader>Gd（vs index，可 do/dp 暂存）在 plugins/git.lua

-- Quick diff: current file vs git HEAD
map("n", "<leader>GD", function()
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
