-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- nvim-tree — file explorer (replaces netrw)
-- 懒加载：setup ~13ms，推迟到首次 <leader>e / <leader>fe；
-- netrw 的禁用必须留在启动期，否则 :e 目录会先被 netrw 接管
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local loaded = false
local function tree(cmd)
    return function()
        if not loaded then
            loaded = true
            require("nvim-tree").setup({
                view = { adaptive_size = true },
                disable_netrw = true,
                hijack_netrw = true,
                sync_root_with_cwd = true,
                update_focused_file = { enable = true },
                filters = {
                    dotfiles = true,
                    custom = { "node_modules", "^.git$" },
                },
                actions = {
                    open_file = {
                        resize_window = true,
                        quit_on_open = true,
                    },
                },
                live_filter = {
                    prefix = "[FILTER]: ",
                    always_show_folders = false,
                },
                git = { timeout = 1000 },
                diagnostics = {
                    enable = true,
                    show_on_dirs = true,
                },
                select_prompts = true,
            })
        end
        vim.cmd(cmd)
    end
end

vim.keymap.set("n", "<leader>e", tree("NvimTreeToggle"), { desc = "NvimTree" })
vim.keymap.set("n", "<leader>fe", tree("NvimTreeFocus"), { desc = "File explorer (focus)" })

-- `nvim <dir>` 启动时仍接管目录（netrw 已禁，不补这个会是空 buffer）
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("NvimTreeDirOpen", { clear = true }),
    callback = function()
        local arg = vim.fn.argv(0)
        if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
            tree("NvimTreeOpen")()
        end
    end,
})
